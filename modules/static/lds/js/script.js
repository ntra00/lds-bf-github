
function setRelLinks(){
	$('a').click(function(e) {
		var rel = $(this).attr('rel');
		if( rel != null && rel != '') {
			e.preventDefault();
			$.address.value(rel);
		}
	});
}



/** ### FACET BOX min max toggle ### */
function toggleFacetBox(link, idStr) {
	if(link.text() == "+") { 
		link.text("-");
	} else {
		link.text("+");
	} 
	$("div.content[id="+idStr+"]").toggle(200);
}

function initFacetToggles() {
	$("span.title-toggle > a").each(function() {
		$(this).toggleClass("hidden");
		$(this).click(function(e){
			e.preventDefault();
			var idStr = $(this).attr("id");
			toggleFacetBox($(this), idStr);
		});
	});
}

function setUpEntityEvents() {
	//alert("entity events");
	$("span.entity","#content").each(function(){		
		$(this).click(function(e){
			e.preventDefault();
			//var typeStr = $(this).attr("type");
			//var textStr = $(this).text();
			//alert("Clicked "+ typeStr+ ": "+ textStr);
		});
	});
}

function paramVal(str, token){
	 var tokenIndex = str.indexOf(token+"=")
	 if(tokenIndex == -1 ) return "";
	 var nextBreak = str.indexOf("&",tokenIndex)

	 var phrase = nextBreak==-1 ? str.substring(tokenIndex) : str.substring(tokenIndex,nextBreak );
	 return phrase.substring(phrase.indexOf("=")+1)
	}



function setupSearch() {

        var textField = $("#search-text",".search-box")
        
        textField.autocomplete({
            minLength: 3,
            delay: 750,
            source:  function (req, add) {        
                var term = $("#search-text",".search-box").val()
                $.get( "/xq/search/suggest.xqy?term=" + escape(term), 
                    function(data) {                        
                        add(data.split(","));
                    } );
            }
            
        });
        
        textField.keyup(function(event) {
            if(event.keyCode == 13) {
                event.preventDefault();
                submitSearchText();
            };
        });
        
        
        $("#button", ".search-box").button();
    
        $("a.search-submit", ".search-box").click(function(e) { 
            e.preventDefault(); 
            submitSearchText();
        });

}

function initFacetDate() {
	$('.datepicker').each(function() {
		$(this).datepicker({
			constrainInput: true,
			changeMonth: true,
			changeYear: true
		});
	});
	
//	$('.datepicker', '#dateafter').datepicker();
//	$('.datepicker', '#datebefore').datepicker();
	
//	{onSelect: function(date,inst) {
//		$(this).val(date);
//		alert(date);
//	}}
	
	
	$('button.facet-date-submit','.facet-box').each(function() {
		var facetId =  $(this).attr('id') ;
		var facetIdAfter = facetId + '1';
		var facetIdBefore = facetId + '2';
		
		var rel = $(this).attr('rel');
		
		$(this).button();
		$(this).click(function(){
			
			var after = $('.datepicker','#dateafter');
			var before = $('.datepicker','#datebefore');

			after.datepicker("option","constrainInput",true);
			before.datepicker("option","constrainInput",true);

			var afterVal = after.val();
			var beforeVal = before.val();
			
			var newRel = "" + rel;
			if(afterVal != null && afterVal != "" ) {
				newRel += "&" + facetIdAfter + "=" + escape(afterVal);
			}
			if(beforeVal != null && beforeVal != "" ) {
				newRel += "&" + facetIdBefore + "=" + escape(beforeVal);
			}
			
			$.address.value(newRel);
			
		});
	});

}

function initFacetMultiButton() {
	$("button.facet-multi-submit",".facet-box").each(function () {
		var facetId =  $(this).attr('id') ;
		var rel = $(this).attr('rel');
		

		
		$(this).button();
        $(this).click(function(e) { 
            e.preventDefault();

            var localRel = '';
            localRel += rel;
            
            var allCheckedVals = [];
            $('input:checked', 'ul#'+facetId).each(function(){
            	allCheckedVals.push( $(this).val() );
            });
            
            var len = allCheckedVals.length;
            for(var i = 0; i < len; ++i){
            	localRel += '&' + facetId + '=' + allCheckedVals[i];
            }

        	$.address.value(localRel);

            
        });
		
	});
}

function initFacetMoreLink(){
	$('a.facet-more', '.facet-box').each(function() {
		var id = $(this).attr("id");
		$(this).click(function(e) {
            e.preventDefault();
            
            
            $.ajax({ 
			   type: "POST", 
			   cache: false,
			   url: '/parts/moreFacet.xqy' , 
			   data: id,
			   dataType: 'html',
			   success: function(data){ 
        			$('#msgcontent').html(data);
        			
        			$('a','#msgcontent').click(function(e) {
                		var rel = $(this).attr('rel');
                		if( rel != null && rel != '') {
                			e.preventDefault();
                			$.address.value(rel);
                			msgClose();

                		}
                	});
        			
        	   }
            });
            
            var block = $("#msgblock");
        	var box = $("#msgbox");
        	block.css("height", $(document).height()); 
        	box.css("top", e.pageY - 150);
        	box.css("left", e.pageX);
        	
            block.fadeIn();  
            box.show('clip',{},500);
            
		});
	});
}

function msgClose() {
    $("#msgbox").hide('clip',{},500);
    $("#msgblock").fadeOut(); 
}

function initPopup() {
	
	
    $("#msgclose").click(function(e){  
        e.preventDefault();
        msgClose();
    }); 
}

function fadeAndRemove( item ) {
	$(item + " > div").each(function () {
		$(this).fadeOut(250, function () {
			$(this).remove();
		});
	});
}

function historyPageInit() {
	$.address.change(function (event){
		if(event.value != "/" && event.value != "") {
			
//			alert(event.value);
			
			var page = paramVal(event.value, 'page');
			
			if(page == 'detail'){
				
				$("#content").html("<div style='width:100%;text-align:center;'>" +
			     		 "	<img src='/static/natlibcat/images/ajax-loader.gif'/>" +
	             "</div>");
			}

			
			 $.ajax({ 
				   type: "POST", 
				   cache: false,
				   url: '/xq/search/parts/ajaxPage.xqy', 
				   data: event.value,
				   dataType: 'html',
				   success: function(data){ 

				 		$(".ui-autocomplete").remove();
				 
			   			$("#search").html($(data).find('#search-results'));
			   			setupSearch();
			   			
			   			
	   					
			   			
			   			if(page == 'search') {
			   				fadeAndRemove( "#content" );
			   				fadeAndRemove( "#results" );
			   			} else if(page == 'results') {
			   				fadeAndRemove( "#content" );
				   			$("#results").html($(data).find('#results-results'));
				   			$("a#kml-link").button();
				   			$("a#link-analysis-link").button();
			   			} else if((page == 'detail') || (page == "viz")) {
			   				fadeAndRemove( "#results" );
		   					$("#content").html($(data).find('#content-results'));
		   					setUpEntityEvents();
			   			} 
			   			
			   			// Hack for dynamic one-column sizing
			   			if(page == "viz"){
				   			$("a#viz-return-link").button();
//			   				$("div.right-column").css("width", "100%"); 
			   			} else {
//			   				$("div.right-column").css("width", "710px"); 
			   			}
			   			
	   					
	   					
				   		$("#facets").html($(data).find('#facet-results'));
						initFacetToggles();
						initFacetMultiButton();
						initFacetDate();
						initFacetMoreLink();
				   		
						setRelLinks();
						
			   			if(page == 'results') {
			   				$("#results").fadeIn(500);
			   			} else if((page == 'detail') || (page == "viz")) {
			   				$("#content").fadeIn(500);
			   			}
			   		
			   	   } 
			 });

		}
			

	});
}



/** ### main script on page ready ### */
$(document).ready(function(){
	//$(document).bind("mouseup", Kolich.Selector.mouseup);

	initPopup();
	
	// On Address Change, change what is in the detail div
	historyPageInit();

});


	
function submitSearchText() {
	var textBox = $("#search-text",".search-box");
	var searchText = textBox.val();
	var existingParams = textBox.attr("rel");
	$.address.value(existingParams + '&t1=' + escape(searchText));
}
