var total_texts = 0;
var current_page = null;

function init() {
    currentidx = 0;
    volumeidx = 0;
    buildViewer();
}

function fromGallery(event, newidx) {
    currentidx = newidx;
    //needs volume
    buildViewer();
}

function buildViewer() {
    //temporary for now until I'm ready to handle multi-volumes
    /*if (pages[0][0] != undefined) {
        pages = pages[0];
    }*/
    Seadragon.Config.autoHideControls = false;
    viewer = new Seadragon.Viewer("viewport-on");
    viewer.addEventListener("resize", toggleContactSheetLink);
    viewer.addEventListener("open", addOverlays);
    browser = Seadragon.Utils.getBrowser();
    total_texts = pages.length;
    total = pages[volumeidx].length;
    current_page = pages[volumeidx][currentidx];
    currentwords = [];
    getCoordinates();
    setNextPrevIdx();
    makePageControl();
    showCaptionControl();
    viewer.openDzi(current_page.url+"/dzi");
}

function switchFromText(event) {
    if (event && event.keyCode == 13) {
        var input = document.getElementById('page_input');
        num = parseInt(input.value);
        if (num >= 0 && num <= total) {
            currentidx = num - 1;
            current_page = pages[volumeidx][currentidx];
            getCoordinates();
            switchTo();
        }
    }
}

function switchFromPrevNext(newidx) {
    currentidx = parseInt(newidx);
    current_page = pages[volumeidx][currentidx];
    getCoordinates();
    if (browser != Seadragon.Browser.IE) {
        var input = document.getElementById('page_input');
        input.value = newidx + 1 + '';
    } else {
        var span = document.getElementById('ie_index_span');
        span_num.innerHTML = newidx + 1 + '';
    }
    switchTo();
}

function getCoordinates() {
    var pnum = currentidx + 1;
    // For non-full text searching (like Gottlieb, don't do the get 
    // if we don't have a search url
    var prefix = $("a#search_tab_url").attr("href");
    if (prefix != undefined) {
        var url = prefix + "&pnum="+pnum+"&gid="+current_page.gid;
        $.ajax({
            type:"GET", 
            url: url, 
            async: false,
            success: function(data){
                var newd = jQuery.parseJSON(data);
                currentwords = newd;
            }
        });
       /* $.get(url, function(data){
            var newd = jQuery.parseJSON(data);
            currentwords = newd;
        });*/
    } else {
        currentwords = [];
    }
}

function fromSearchResults(event, new_page_idx, new_volume_idx, newwords) {
    currentidx = new_page_idx;
    volumeidx = new_volume_idx;
    current_page = pages[volumeidx][currentidx];
    currentwords = newwords;
    switchTo();
    scroll(0,0);
    return false;
}

function switchTo() {
    viewer.close();
    total = pages[volumeidx].length;
    setNextPrevIdx();
    makePageControl();
    showCaptionControl();
    viewer.openDzi(current_page.url+"/dzi");
}

function setNextPrevIdx() {
    previdx = null;
    nextidx = null;
    if (currentidx + 1 < total) {
        nextidx = currentidx + 1;
    }
    if (currentidx - 1 >= 0) {
        previdx = currentidx - 1;
    }
}

function makePageControl() {
    viewer.removeControl(pageControl);
    pageControl = document.createElement("div");
    pageControl.className = "page_control";
    pageControl.id = "page_control";
    if (total_texts > 1) {
        //build out text control
        text_span = document.createElement("span");
        text_span.innerHTML += 'Text:&nbsp;'+String(volumeidx+1)+'&nbsp;of ' + total_texts + '&nbsp;|&nbsp;';
        pageControl.appendChild(text_span);
    }
    span1 = document.createElement("span");
    span1.innerHTML = 'Image:&nbsp;';
    pageControl.appendChild(span1);
    
    // also when total is '1'?
    if (browser != Seadragon.Browser.IE && total > 1) {
        var input = document.createElement("input");
        input.id = "page_input";
        input.type = "text";
        input.value = currentidx + 1 + '';
        input.size = 1;
        pageControl.appendChild(input);
        Seadragon.Utils.addEvent(input, "keypress", switchFromText);
    } else {
        span_num = document.createElement("span");
        span_num.id = 'ie_index_span';
        span_num.innerHTML = currentidx + 1 + '';
        pageControl.appendChild(span_num);
    }
    
    span2 = document.createElement("span");
    span2.innerHTML += '&nbsp;of ' + total + '';
    pageControl.appendChild(span2);
    
    createPrevNext(pageControl);
    addContactSheetLink(pageControl);
    addDownloadLink(pageControl);
    viewer.addControl(pageControl, Seadragon.ControlAnchor.TOP_RIGHT);
}

function createPrevNext(pageControl) {
    elem = document.getElementById('page_span');
    if (elem != null) {
        pageControl.removeChild(elem);
    }
    if (total > 1) {
        var arrow_span = document.createElement("span");
        arrow_span.id = "page_span";
        
        var prev_elem = null;
        //var prev_elem_text = document.createTextNode('\u27ea Previous');
        var prev_elem_text = document.createTextNode('<< Previous');
        if (previdx == null) {
            prev_elem = document.createElement("span");
            prev_elem.className = "arrow_off";
            prev_elem.appendChild(prev_elem_text);
        } else {
            prev_elem = document.createElement("a");
            prev_elem.className = "arrow_on";
            prev_elem.href = "#";
            prev_elem.setAttribute("onclick", "switchFromPrevNext(previdx)");
            prev_elem.appendChild(prev_elem_text);
        }
        
        var next_elem = null;
        //var next_elem_text = document.createTextNode('Next \u27eb');
        var next_elem_text = document.createTextNode('Next >>');
        if (nextidx == null) {
            next_elem = document.createElement("span");
            next_elem.className = "arrow_off";
            next_elem.appendChild(next_elem_text);
        } else {
            next_elem = document.createElement("a");
            next_elem.className = "arrow_on";
            next_elem.href = "#";
            next_elem.setAttribute("onclick", "switchFromPrevNext(nextidx)");
            next_elem.appendChild(next_elem_text);
        }
            
        var text = document.createTextNode(" | ");
        arrow_span.appendChild(text);
        //var br = document.createElement("br");
        //arrow_span.appendChild(br);
        arrow_span.appendChild(prev_elem);
        var span1 = createSpace();
        arrow_span.appendChild(span1);
        arrow_span.appendChild(next_elem);
        pageControl.appendChild(arrow_span);
    }
}

function addDownloadLink(pageControl) {
    if (current_page.master != null) {
        elem = document.getElementById('download_span');
        if (elem != null) {
            pageControl.removeChild(elem);
        }
        var span = document.createElement("span");
        span.id = "download_span";
        var text = document.createTextNode(" | ");
        var a = document.createElement("a");
        var alinkText = document.createTextNode("Download Tiff");
        a.href = current_page.master;
        a.appendChild(alinkText);
        span.appendChild(text);
        span.appendChild(a);
        pageControl.appendChild(span);
    }
}

function addContactSheetLink(pageControl) {
    if (!viewer.isFullPage()) {
        elem = document.getElementById('contact_span');
        if (elem != null) {
            pageControl.removeChild(elem);
        }
        var span = document.createElement("span");
        span.id = "contact_span";
        var text = document.createTextNode(" | ");
        var a = document.createElement("a");
        a.id = "contactsheet_sd";
        var alinkText = document.createTextNode("All images");
        a.href = "#";
        a.appendChild(alinkText);
        span.appendChild(text);
        span.appendChild(a);
        pageControl.appendChild(span);
        Seadragon.Utils.addEvent(span, "click", displayContactSheet);
    }
}

function toggleContactSheetLink() {
    if (viewer.isFullPage()) {
        $("span#contact_span").hide();
    } else {
        $("span#contact_span").show();
    }
}

function showCaptionControl() {
    viewer.removeControl(captionControl);
    if (current_page.caption != null) {
        // display 'Show Caption' link
        captionControl = document.createElement("div");
        captionControl.className = "caption";
        var alink = document.createElement("a");
        var alinkText = document.createTextNode("Show Caption");
        alink.href = "#";
        alink.appendChild(alinkText);
        captionControl.appendChild(alink);
        Seadragon.Utils.addEvent(captionControl, "click", showCaption);
        viewer.addControl(captionControl, Seadragon.ControlAnchor.BOTTOM_RIGHT);
    }
}

function showCaption() {
    viewer.removeControl(captionControl);
    // display caption and 'Hide Caption' link
    captionControl = document.createElement("div");
    captionControl.className = "caption";
    captionControl.innerHTML = current_page.caption;
    var br = document.createElement("br");
    alink = document.createElement("a");
    var alinkText = document.createTextNode("Hide Caption");
    alink.href = "#";
    // so browser shows it as link
    alink.appendChild(alinkText);
    captionControl.appendChild(br);
    captionControl.appendChild(alink);
    Seadragon.Utils.addEvent(captionControl, "click", showCaptionControl);
    viewer.addControl(captionControl, Seadragon.ControlAnchor.BOTTOM_RIGHT);
}

function addOverlays(viewer){
    if (currentwords != null) {
        for (var i=0;i<currentwords.length;i++) {
            xint = parseFloat(currentwords[i].x)
            yint = parseFloat(currentwords[i].y)
            widthint = parseFloat(currentwords[i].width)
            heightint = parseFloat(currentwords[i].height)
            addOverlay(viewer,xint,yint,widthint,heightint)
        }
    }
}

function addOverlay(viewer, x, y, width, height){
    var div = document.createElement("div");
    var rect = new Seadragon.Rect(x,y,width,height);
    div.className = "overlay";
    viewer.drawer.addOverlay(div, rect);
}

function createSpace() {
    var span = document.createElement('span');
    var spanText = document.createTextNode("\u00a0\u00a0");
    span.appendChild(spanText);
    return span;
}

function displayContactSheet(event) {
    Seadragon.Utils.cancelEvent(event);  // don't process link
    //$('a#contactsheet').trigger('click');
    var viewport =  $("div#viewport-on");
    viewport.empty();
    viewport.append('<p style="color:white">Loading...</p>');
    var thumb_div = $("<div/>").attr({id: "thumbs", "class": "navigation"});
    var list = $("<ul/>").attr({"class": "thumbs noscript"});
    for (var i = 0; i < total; i++) {
        var url = pages[volumeidx][i].url + '/100';
        //add volume when it's added to files array
        var id = "img_"+i;
        var code = $("<code>"+url+"</code>").attr("id",id);
        code.css({'display':'none'});
        var a = $("<a/>").attr({"class": "thumb", href: "#", onClick: "fromGallery(event," + i + ");"})
        .append(code).append($("<span/>"));
        //.append($("<img/>").attr({"src": url})).append($("<span/>"));
        var li = null;
        if (currentidx == i) {
            li = $("<li/>").attr({"class":"selected"});
        } else {
            li = $("<li/>");
        }
        list.append(li.append(a));
    }
    thumb_div.append(list);
    $("div#viewport-on").empty().append(thumb_div);
    
    // We only want these styles applied when javascript is enabled
    $('div.navigation').css({'width' : '600px', 'float' : 'left'});
    //$('div.content').css('display', 'block');
    
    // Initially set opacity on thumbs and add
    // additional styling for hover effect on thumbs
    var onMouseOutOpacity = 0.67;
    $('#thumbs ul.thumbs li').opacityrollover({
        mouseOutOpacity: onMouseOutOpacity,
        mouseOverOpacity: 1.0,
        fadeSpeed: 'fast',
        exemptionSelector: '.selected'
    });
    
    // Initialize Advanced Galleriffic Gallery
    var gallery = $('#thumbs').galleriffic({
        delay: 3000,
        numThumbs: 10,
        currentidx: currentidx,
        preloadAhead: 0,
        enableTopPager: true,
        enableBottomPager: false,
        maxPagesToShow: 7,
        nextPageLinkText: 'Next &raquo;',
        prevPageLinkText: '&laquo; Prev',
        enableKeyboardNavigation: false,
        syncTransitions: true,
        defaultTransitionDuration: 900,
        onPageTransitionOut: function (callback) {
            this.fadeTo('fast', 0.0, callback);
        },
        onPageTransitionIn: function () {
            this.fadeTo('fast', 1.0);
        }
    });
}
