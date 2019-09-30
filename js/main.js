	const map = L.map('map').setView([62, -152], 5);

/*
	// Mapbox Streets
	L.tileLayer('https://api.tiles.mapbox.com/v4/{id}/{z}/{x}/{y}.png?access_token=pk.eyJ1IjoibWFwYm94IiwiYSI6ImNpejY4NXVycTA2emYycXBndHRqcmZ3N3gifQ.rJcFIG214AriISLbB6B5aw', {
		maxZoom: 18,
		attribution: 'Map data &copy; <a href="https://www.openstreetmap.org/">OpenStreetMap</a> contributors, ' +
			'<a href="https://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, ' +
			'Imagery © <a href="https://www.mapbox.com/">Mapbox</a>',
		id: 'mapbox.streets'
	}).addTo(map);
*/
	// Esri World Imagery
	L.esri.basemapLayer('ImageryClarity').addTo(map);

/*
	// Park Tiles 4 (retina display problem on Safari on MacOS)
	L.tileLayer('https://api.mapbox.com/styles/v1/nps/cjt94v8pu23wh1fqug0cnviat/tiles/512/{z}/{x}/{y}?access_token=pk.eyJ1IjoibnBzIiwiYSI6IkdfeS1OY1UifQ.K8Qn5ojTw4RV1GwBlsci-Q', {
		detectRetina: true,
		attribution: "&copy; <a href='https://www.mapbox.com/about/maps/' target='_blank'>Mapbox</a> &copy; <a href='https://www.openstreetmap.org/copyright' target='_blank'>OpenStreetMap</a> contributor",
		id: 'nps.parktiles',
		maxZoom: 12,
	}).addTo(map);
*/
	// AKR GIS Facilities Map Service
	//const facilitiesLayer = 
	L.esri.dynamicMapLayer({
		url: 'https://akrgis.nps.gov/arcgis/rest/services/AKR_Apps/FMSS_web_service/MapServer',
		opacity: 1.0,
		//minZoom:8
	}).addTo(map).bindPopup(
		function(err, featureCollection, response){
			var count = featureCollection.features.length;
    		return (count) ? count + ' features' : false;
	});

    function find(text) {
      map.closePopup();
      controlSearch.searchText(text);
      controlSearch._handleKeypress({keyCode: 13});
    }

	function buildPopup(feature) {
		let popup = 
		`<div class="title">Location ${feature.properties['ID']}</div>` + 
					'<div class="content">' + 
					`<div class="description"><p>${feature.properties['Name']}</p>` + 
					'<table>';
			if (feature.properties.hasOwnProperty('DM')) {
				popup += 
						`<tr><td class="att_name">ParkID</td><td>${feature.properties['Park_Id']}</td></tr>` +
						`<tr><td class="att_name">Description</td><td>${feature.properties['Desc']}</td></tr>` +
						`<tr><td class="att_name">Value</td><td>${feature.properties['CRV']}</td></tr>` +
						`<tr><td class="att_name">Def. Maint</td><td>${feature.properties['DM']}</td></tr>` +
						`<tr><td class="att_name">Age</td><td>${feature.properties['Age']}</td></tr>` +
						`<tr><td class="att_name">Size</td><td>${feature.properties['Size']}</td></tr>` +
						`<tr><td class="att_name">Status</td><td>${feature.properties['Status']}</td></tr>`;
			} else {
				popup += `<tr><td class="att_name">ParkID</td><td>${feature.properties['Desc']}</td></tr>`
			}
			popup += `<tr><td class="att_name">Parent</td><td><a href="javascript:find('${feature.properties['Parent']}')">${feature.properties['Parent']}</a></td></tr>` +
				'</table></div>';

	}
	const clusterOptions = {
		maxClusterRadius: 60,
		//showCoverageOnHover: false,
		polygonOptions: {color: '#7A904F'},
		iconCreateFunction: function (cluster) {
			var childCount = cluster.getChildCount();
			var content = '<div><span>' + childCount + '</span></div>'
			var style = 'marker-cluster marker-cluster-';
			var size = 40;
			if (childCount < 10) {
				style += 'small';
			} else if (childCount < 100) {
				style += 'medium';
				size += 10;
			} else {
				style += 'large';
				size += 20;
			}
			return new L.DivIcon({ html: content, className: style, iconSize: new L.Point(size,size) });
		},
	};

	const searchOptions = {
		propertyName: "ID",
		zoom: 18,
		textPlaceholder:"FMSS ID",
		initial: false,
		hideMarkerOnCollapse: true,
		buildTip: function(text, val) {
			var type = val.layer.feature.properties['Kind'];
			var name = val.layer.options.name;
			return '<a href="#" class="'+name+'">'+text+' <b>'+type+'</b></a>';
		}
	};
	
	const geoCsvOpts = {
		firstLineTitles: true,
		fieldSeparator: ',',
		latitudeTitle: 'Latitude',
		longitudeTitle: 'Longitude',
		onEachFeature: function (feature, layer) {
			var popup = buildPopup(feature)
			layer.bindPopup(popup);
			var tooltip = feature.properties['ID'] === 'N/A' ? feature.properties['Name'] : feature.properties['ID'];
			layer.bindTooltip(tooltip,{sticky:true});
		}
	};

	const markers = L.markerClusterGroup(clusterOptions);
	searchOptions.layer = markers;
	const controlSearch = new L.Control.Search(searchOptions);
	var photos;
	map.addLayer(markers);
	map.addControl(controlSearch);

	fetch('data/assets.csv')
		.then(response => response.text())
		.then(data => markers.addLayer(L.geoCsv(data, geoCsvOpts)));
	fetch('data/facilities.csv')
		.then(response => response.text())
		.then(data => markers.addLayer(L.geoCsv(data, geoCsvOpts)));
	fetch("/fmss/photos.json")
		.then(response => response.json())
		.then(data => photos = data);
	