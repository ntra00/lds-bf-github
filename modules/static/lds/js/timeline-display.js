var tl;
function onLoad() {
    var eventSource_soa = new Timeline.DefaultEventSource();
    var eventSource_culture = new Timeline.DefaultEventSource();
    var eventSource_politics = new Timeline.DefaultEventSource();
    var theme = new Timeline.getDefaultTheme();
    theme.timeline_start = new Date(Date.UTC(1757,0,1));
    theme.timeline_stop = new Date(Date.UTC(2000,0,1));
    
    var bandInfos = [
     Timeline.createBandInfo({
        eventSource: eventSource_soa,
        date:           "Jan 28 1759",
         width:          "30%", 
         intervalUnit:   Timeline.DateTime.YEAR, 
         intervalPixels: 200,
         theme: theme
     }),
     Timeline.createBandInfo({
        eventSource: eventSource_culture,
        date:           "Jan 28 1759",
         width:          "30%", 
         intervalUnit:   Timeline.DateTime.YEAR, 
         intervalPixels: 200,
         theme: theme
     }),
     Timeline.createBandInfo({
        eventSource: eventSource_politics,
        date:           "Jan 28 1759",
         width:          "30%", 
         intervalUnit:   Timeline.DateTime.YEAR, 
         intervalPixels: 200,
         theme: theme
     }),
     Timeline.createBandInfo({
        date:           "Jan 28 1759",
         width:          "10%", 
         intervalUnit:   Timeline.DateTime.DECADE, 
         intervalPixels: 200,
         theme: theme
     })
   ];
   bandInfos[1].syncWith = 0;
   bandInfos[2].syncWith = 0;
   bandInfos[3].syncWith = 0;
   bandInfos[3].highlight = true;
   
   bandInfos[0].decorators = [
    new Timeline.SpanHighlightDecorator({
        startDate: theme.timeline_start,
        endDate: theme.timeline_start,
        startLabel: "",
        endLabel: "Song of America",
    })
   ];
   
   bandInfos[1].decorators = [
    new Timeline.SpanHighlightDecorator({
        startDate: theme.timeline_start,
        endDate: theme.timeline_start,
        startLabel: "",
        endLabel: "Culture",
    })
   ];
   
    bandInfos[2].decorators = [
    new Timeline.SpanHighlightDecorator({
        startDate: theme.timeline_start,
        endDate: theme.timeline_start,
        startLabel: "",
        endLabel: "Politics",
    })
   ];
   
   tl = Timeline.create(document.getElementById("my-timeline"), bandInfos);
   //eventSource.loadJSON(json_data,"");
   Timeline.loadXML("/static/natlibcat/xml/timeline_soa.xml", function(xml, url) {eventSource_soa.loadXML(xml,url); });
   Timeline.loadXML("/static/natlibcat/xml/timeline_culture.xml", function(xml, url) {eventSource_culture.loadXML(xml,url); });
   Timeline.loadXML("/static/natlibcat/xml/timeline_politics.xml", function(xml, url) {eventSource_politics.loadXML(xml,url); });
}

var resizeTimerID = null;
function onResize() {
     if (resizeTimerID == null) {
         resizeTimerID = window.setTimeout(function() {
             resizeTimerID = null;
             tl.layout();
         }, 500);
     }
}