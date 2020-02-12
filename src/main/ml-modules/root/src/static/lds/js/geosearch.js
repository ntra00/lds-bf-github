var kmlurl;
$(function(){
    var latlng = new google.maps.LatLng(5, 20);
    var myOptions = { zoom: 4, center: latlng, mapTypeId: google.maps.MapTypeId.ROADMAP };
    var map = new google.maps.Map(document.getElementById("map_canvas"), myOptions);
    var creator = new PolygonCreator(map);
    var kmlurl = "http://marklogic3.loc.gov:8200/nlc/kml.xqy?svcid=loc.gmd.africasets.2001626729";
    var ctaLayer = new google.maps.KmlLayer('http://monarchos.com/africa.kml', { suppressInfoWindows: false, map: map } );
    // Construct the user's ROI polygon
    var roi = new google.maps.Polygon({ paths: roipoly, strokeColor: "#FF0000", strokeOpacity: 0.8, strokeWeight: 2, fillColor: "#FF0000", fillOpacity: 0.35 });
    roi.setMap(map);
    //ctaLayer.setMap(map);
    google.maps.event.addListener(ctaLayer, 'click', function() {
        $('#geo-coords').attr('value', creator.showData());
    });
    $('#geoShowData').click(function(e){
        e.preventDefault();
        if(null==creator.showData()){
            alert('Please first create a polygon');
        }else{
            $('#geo-coords').attr('value', creator.showData());
            $('#geoform-input').submit()
        }
    });
    $('#geoClearData').click(function(){
        creator.destroy();
    });
});
