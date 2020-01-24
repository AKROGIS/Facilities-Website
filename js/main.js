'use strict'

/* global L */

export default class FacilityMap {
  constructor (mapDivId) {
    this.map = L.map(mapDivId).setView([62, -152], 5)
    this.photos = undefined
    this.children_for = undefined
    this.assets_for = undefined
    this.searchControl = undefined
  }

  find (text) {
    this.map.closePopup()
    this.searchControl.searchText(text)
    this.searchControl._handleKeypress({ keyCode: 13 })
  }

  configure () {

		// Park Tiles 4
		// Use either 256 or 512 (512 has text that is too small to read on MacBook)
		// Use either @2x or ''; @2x is crisper on the MacBook
		L.tileLayer('https://api.mapbox.com/styles/v1/nps/{style_id}/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoibnBzIiwiYSI6IkdfeS1OY1UifQ.K8Qn5ojTw4RV1GwBlsci-Q', {
      attribution: "&copy; <a href='https://www.mapbox.com/about/maps/' target='_blank'>Mapbox</a> &copy; <a href='https://www.openstreetmap.org/copyright' target='_blank'>OpenStreetMap</a> contributors",
			style_id: "cjt94v8pu23wh1fqug0cnviat",  //Park Tiles Standard
			//style_id: "cjua0op0k4q301gpbb7o7wc6t",  //Park Tiles Light
			//style_id: "cju8w7m1l50bu1frs10dajli6",  //Park Tiles Slate
      maxZoom: 20
		}).addTo(this.map)


    // Esri World Imagery
    L.esri.basemapLayer('ImageryClarity', {minZoom: 15, maxZoom: 19, opacity: 0.8}).addTo(this.map)

    /*
    // Original ParkTiles
    L.tileLayer('https://a.tiles.mapbox.com/v4/nps.2yxv8n84/{z}/{x}/{y}@2x.png?access_token=pk.eyJ1IjoibnBzIiwiYSI6IkdfeS1OY1UifQ.K8Qn5ojTw4RV1GwBlsci-Q', {
      attribution: "&copy; <a href='https://www.mapbox.com/about/maps/' target='_blank'>Mapbox</a> &copy; <a href='https://www.openstreetmap.org/copyright' target='_blank'>OpenStreetMap</a> contributors",
      maxZoom: 20
    }).addTo(this.map)

		// Park Tiles 4
		// Use either 256 or 512 (512 has text that is too small to read on MacBook)
		// Use either @2x or ''; @2x is crisper on the MacBook
		L.tileLayer('https://api.mapbox.com/styles/v1/nps/{style_id}/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoibnBzIiwiYSI6IkdfeS1OY1UifQ.K8Qn5ojTw4RV1GwBlsci-Q', {
      attribution: "&copy; <a href='https://www.mapbox.com/about/maps/' target='_blank'>Mapbox</a> &copy; <a href='https://www.openstreetmap.org/copyright' target='_blank'>OpenStreetMap</a> contributors",
			style_id: "cjt94v8pu23wh1fqug0cnviat",  //Park Tiles Standard
			//style_id: "cjua0op0k4q301gpbb7o7wc6t",  //Park Tiles Light
			//style_id: "cju8w7m1l50bu1frs10dajli6",  //Park Tiles Slate
      maxZoom: 20
		}).addTo(this.map)

    // Esri World Imagery
    L.esri.basemapLayer('ImageryClarity', {minZoom: 15, maxZoom: 19, opacity: 0.8}).addTo(this.map)

    // AKR GIS Facilities Map Service
    L.esri.dynamicMapLayer({
      url: 'https://akrgis.nps.gov/arcgis/rest/services/AKR_Apps/FMSS_web_service/MapServer',
      opacity: 1.0
      // minZoom:8
    }).addTo(this.map).bindPopup(function (err, featureCollection) {
      if (err) {
        return err.message
      } else {
        var count = featureCollection.features.length
        return (count) ? count + ' features' : false
      }
    })
    */

    function has_key(obj,key) {
      // returns true if obj has a owned property called key
      // Guards against redefinition of hasOwnProperty, see https://eslint.org/docs/rules/guard-for-in
      return Object.prototype.hasOwnProperty.call(obj, key)
    }

    function buildPopup (feature, photos, children, assets) {
      function generic_row(data, title, title_plural) {
        let row = ''
        if (!Array.isArray(data)) { return row}
        if (data.length === 0) { return row};
        if (data.length === 1) {
          var id = data[0].i;
          var name = data[0].d;
          if (data[0].c == 0) {
            row = '<tr><td class="att_name">' + title + '</td><td>' + id + ' - ' + name + '</td></tr>'
          } else {
            row = '<tr><td class="att_name">' + title + '</td><td><a href="javascript:find(\'' + id + '\')">' + id + ' - ' + name + '</a></td></tr>'
          }
        } else {
          row = '<tr><td class="att_name">' + title_plural + '</td><td><ul>'
          data.forEach(element => {
            var id = element.i;
            var name = element.d;
            var item;
            if (element.c == 0) {
              item = '<li>' + id + ' - ' + name + '</li>'
            } else {
              item = '<li><a href="javascript:find(\'' + id + '\')">' + id + ' - ' + name + '</a></li>'
            }
            row += item;
          });
          row += '</ul></td></tr>'
        }
        return row
      }

      const title = has_key(feature.properties, 'DM') ? 'Location' : 'Asset'
      let popup =
        `<div class="title">${title} ${feature.properties.ID}</div>` +
        '<div class="content">' +
        `<div class="description"><p>${feature.properties.Name}</p>` +
        '<table>'
      if (title === 'Location') {
        popup +=
        `<tr><td class="att_name">ParkID</td><td>${feature.properties.Park_Id}</td></tr>` +
        `<tr><td class="att_name">Description</td><td>${feature.properties.Desc}</td></tr>` +
        `<tr><td class="att_name">Value</td><td>${feature.properties.CRV}</td></tr>` +
        `<tr><td class="att_name">Def. Maint</td><td>${feature.properties.DM}</td></tr>` +
        `<tr><td class="att_name">Age</td><td>${feature.properties.Age}</td></tr>` +
        `<tr><td class="att_name">Size</td><td>${feature.properties.Size}</td></tr>` +
        `<tr><td class="att_name">Status</td><td>${feature.properties.Status}</td></tr>` +
        generic_row(children, 'Child', 'Children') +
        generic_row(assets, 'Asset', 'Assets')
      } else {
        popup += `<tr><td class="att_name">ParkID</td><td>${feature.properties.Desc}</td></tr>`
      }
      popup +=
        '<tr><td class="att_name">Parent</td><td>' +
        `<a href="javascript:find('${feature.properties.Parent}')">${feature.properties.Parent}</a>`
      if (photos) {
        let photoSection = '</td></tr><ul id="photo-list" class="clearfix">'
        photos.forEach((name, i) => {
          const thumbUrl = '/fmss/photos/thumb/' + name
          const fullUrl = '/fmss/photos/web/' + name
          const style = i === 0 ? 'block' : 'none'
          photoSection += `<li style="display:${style};"><a href="${fullUrl}" target="_blank"><img height="150px" width="200px" src="${thumbUrl}"></a></li>`
        })
        photoSection += '</ul>'
        if (photos.length > 1) {
          photoSection += '<div style="float: right;"><button id="prev-photo" class="btn btn-circle disabled prev">&lt;</button><button id="next-photo" class="btn btn-circle next">&gt;</button></div>'
        }
        popup += photoSection
      }
      popup += '</td></tr></table></div>'
      // I can't add event to the photo carousel buttons, because the doc fragment will not be added to the DOM until later by the framework
      // I will set up listeners later
      return popup
    }

    const clusterOptions = {
      maxClusterRadius: 20,
      showCoverageOnHover: false,
      // polygonOptions: { color: '#7A904F' },
      iconCreateFunction: function (cluster) {
        var childCount = cluster.getChildCount()
        var content = '<div><span>' + childCount + '</span></div>'
        var style = 'marker-cluster marker-cluster-'
        var size = 40
        if (childCount < 10) {
          style += 'small'
        } else if (childCount < 100) {
          style += 'medium'
          size += 10
        } else {
          style += 'large'
          size += 20
        }
        return new L.DivIcon({ html: content, className: style, iconSize: new L.Point(size, size) })
      }
    }

    const searchOptions = {
      propertyName: 'Index',
      zoom: 18,
      initial: false,
      hideMarkerOnCollapse: true,
      buildTip: function (text, val) {
        var type = val.layer.feature.properties.Kind
        var name = val.layer.options.name
        return '<a href="#" class="' + name + '">' + text + ' <b>' + type + '</b></a>'
      }
    }
    function buildIcon(symbol) {
      return L.icon({
        iconUrl: symbol,
        iconSize: [14,14],
        iconAnchor: [7,22],
        popupAnchor: [0,-15],
        tooltipAnchor: [0,-15],
        shadowUrl: 'images/marker-small.svg',
        shadowSize: [24,39],
        shadowAnchor: [12,27]
      })
    }
    function buildAssetIcon(symbol) {
      return L.icon({
        iconUrl: symbol,
        iconSize: [10,10],
        iconAnchor: [4,16],
        popupAnchor: [0,-11],
        tooltipAnchor: [0,-11],
        shadowUrl: 'images/marker-asset.svg',
        shadowSize: [18,28],
        shadowAnchor: [8,19]
      })
    }
    const roadIcon = buildIcon('images/car-s.svg')
    const trailIcon = buildIcon('images/trail-s.svg')
    const parkingIcon = buildIcon('images/parking-s.svg')
    const bridgeIcon = buildIcon('images/bridge-s.svg')
    const buildingIcon = buildIcon('images/ranger-s.svg')

    const roadAssetIcon = buildAssetIcon('images/car-s.svg')
    const trailAssetIcon = buildAssetIcon('images/trail-s.svg')
    const parkingAssetIcon = buildAssetIcon('images/parking-s.svg')
    const bridgeAssetIcon = buildAssetIcon('images/bridge-s.svg')
    const buildingAssetIcon = buildAssetIcon('images/ranger-s.svg')

    const unknownIcon = buildIcon('?')

    const geoCsvOpts = {
      firstLineTitles: true,
      fieldSeparator: ',',
      latitudeTitle: 'Latitude',
      longitudeTitle: 'Longitude',
      pointToLayer: function(geoJsonPoint, latlng) {
        const asset = ! has_key(geoJsonPoint.properties, 'DM')
        var icon = unknownIcon;
        switch (geoJsonPoint.properties['Kind']) {
          case 'Building' : icon = asset ? buildingAssetIcon : buildingIcon; break;
          case 'Road' : icon = asset ? roadAssetIcon : roadIcon; break;
          case 'Parking' : icon = asset ? parkingAssetIcon : parkingIcon; break;
          case 'Bridge' : icon = asset ? bridgeAssetIcon : bridgeIcon; break;
          case 'Trail' : icon = asset ? trailAssetIcon : trailIcon; break;
        }
        if (asset) {icon.className = 'asset'}
        return L.marker(latlng, {icon: icon})
      },
      onEachFeature: function (feature, layer) {
        // Create a dynamic multi part search field
        const id = feature.properties.ID
        feature.properties.Index = id + ' - ' + feature.properties.Desc
        var popup = buildPopup(feature, this.photos[feature.properties.Photo_Id], this.children_for[id], this.assets_for[id])
        // TODO: Adjust width/height based on available screen size  ('90%' does not work)
        layer.bindPopup(popup, {maxWidth:500, maxHeight:800})
        var tooltip = id === 'N/A' ? feature.properties.Name : id
        layer.bindTooltip(tooltip, { sticky: true })
      }.bind(this)
    }
    const markers = L.markerClusterGroup(clusterOptions)
    searchOptions.layer = markers
    this.searchControl = new L.Control.Search(searchOptions)
    this.map.addLayer(markers)
    this.map.addControl(this.searchControl)

    Promise.all([
      window.fetch('/fmss/photos.json').then(response => response.json()),
      window.fetch('data/facilities.csv').then(response => response.text()),
      window.fetch('data/assets.csv').then(response => response.text()),
      window.fetch('data/children.json').then(response => response.json()),
      window.fetch('data/assets.json').then(response => response.json())
    ]).then(([photos, facilities, assets, children_for, assets_for]) => {
      this.photos = photos
      this.children_for = children_for
      this.assets_for = assets_for
      markers.addLayer(L.geoCsv(facilities, geoCsvOpts))
      markers.addLayer(L.geoCsv(assets, geoCsvOpts))
    })

    function changeImage (direction) {
      var ul = document.getElementById('photo-list');
      var previous = document.getElementById('prev-photo');
      var next = document.getElementById('next-photo');
      var lis = ul.childNodes;
      var maxImg = lis.length;
      var curImg;
      var j;
      var li;

      for (j = 0; j < lis.length; j++) {
        li = lis[j];

        if (li.style.display !== 'none') {
          curImg = j;
          break;
        }
      }

      if ((curImg + direction) < maxImg && (curImg + direction) > -1) {
        for (j = 0; j < lis.length; j++) {
          li = lis[j];

          if (j === (curImg + direction)) {
            li.style.display = 'block';
          } else {
            li.style.display = 'none';
          }
        }
      }

      if ((curImg + direction) <= 0) {
        L.DomUtil.addClass(previous, 'disabled');
      } else {
        L.DomUtil.removeClass(previous, 'disabled');
      }

      if ((curImg + direction + 1) >= maxImg) {
        L.DomUtil.addClass(next, 'disabled');
      } else {
        L.DomUtil.removeClass(next, 'disabled');
      }
    }

    document.addEventListener('click',function(e){
      if(e.target && e.target.id== 'prev-photo'){
        changeImage (-1);
      }
      if(e.target && e.target.id== 'next-photo'){
        changeImage (1);
      }
    });

  }
}
