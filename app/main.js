/**
 * Created by regan_sarwas on 7/8/14.
 */
/*
 * This is loaded before the map is loaded or configured
 */
function showPhotos(id) {
    window.alert('You clicked ' + id);
}

function addClick() {
    var map = NPMap.config.L;
    map.on('click', function(e) {window.alert(e.latlng)});
}

function setupSearch() {
    var map = NPMap.config.L;
    var controlSearch = new L.Control.Search({
        layer: NPMap.config.overlays[0].L,
        propertyName: "ID",
        zoom: 18,
        text:"FMSS ID",
        initial: false});
    map.addControl( controlSearch );
}
