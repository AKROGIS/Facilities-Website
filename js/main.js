'use strict'

/* global L */

export default class FacilityMap {
  constructor (mapDivId) {
    this.map = L.map(mapDivId).setView([62, -152], 5)
    this.photos = undefined
    this.searchControl = undefined
  }

  find (text) {
    this.map.closePopup()
    this.searchControl.searchText(text)
    this.searchControl._handleKeypress({ keyCode: 13 })
  }

  configure () {
    // Mapbox Streets
    L.tileLayer('https://api.tiles.mapbox.com/v4/{id}/{z}/{x}/{y}.png?access_token=pk.eyJ1IjoibWFwYm94IiwiYSI6ImNpejY4NXVycTA2emYycXBndHRqcmZ3N3gifQ.rJcFIG214AriISLbB6B5aw', {
      maxZoom: 20,
      attribution: 'Map data &copy; <a href="https://www.openstreetmap.org/">OpenStreetMap</a> contributors, ' +
                  '<a href="https://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, ' +
                  'Imagery © <a href="https://www.mapbox.com/">Mapbox</a>',
      id: 'mapbox.streets'
    }).addTo(this.map)

    L.esri.basemapLayer('ImageryClarity', {minZoom: 15, maxZoom: 19, opacity: 0.8}).addTo(this.map)

    /*
    // Park Tiles 4 (retina display problem on Safari on MacOS)
    L.tileLayer('https://api.mapbox.com/styles/v1/nps/cjt94v8pu23wh1fqug0cnviat/tiles/512/{z}/{x}/{y}?access_token=pk.eyJ1IjoibnBzIiwiYSI6IkdfeS1OY1UifQ.K8Qn5ojTw4RV1GwBlsci-Q', {
      detectRetina: true,
      attribution: "&copy; <a href='https://www.mapbox.com/about/maps/' target='_blank'>Mapbox</a> " +
                  "&copy; <a href='https://www.openstreetmap.org/copyright' target='_blank'>OpenStreetMap</a> contributor",
      id: 'nps.parktiles',
      maxZoom: 12
    }).addTo(this.map)

    // Esri World Imagery
    L.esri.basemapLayer('ImageryClarity').addTo(this.map)

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

    function buildPopup (feature, photos) {
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
        `<tr><td class="att_name">Status</td><td>${feature.properties.Status}</td></tr>`
      } else {
        popup += `<tr><td class="att_name">ParkID</td><td>${feature.properties.Desc}</td></tr>`
      }
      popup +=
        '<tr><td class="att_name">Parent</td><td>' +
        `<a href="javascript:find('${feature.properties.Parent}')">${feature.properties.Parent}</a>`
      if (photos) {
        let photoSection = '</td></tr><ul class="clearfix">'
        photos.forEach((name, i) => {
          const thumbUrl = '/fmss/photos/thumb/' + name
          const fullUrl = '/fmss/photos/web/' + name
          const style = i === 0 ? 'block' : 'none'
          photoSection += `<li style="display:${style};"><a href="${fullUrl}" target="_blank"><img height="150px" width="200px" src="${thumbUrl}"></a></li>`
        })
        photoSection += '</ul>'
        if (photos.length > 1) {
          photoSection += '<div style="float: right;"><button class="btn btn-circle disabled prev">&lt;</button><button class="btn btn-circle next">&gt;</button></div>'
        }
        popup += photoSection
      }
      popup +=
        '</td></tr></table></div>`'
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
        feature.properties.Index = feature.properties.ID + ' - ' + feature.properties.Desc
        var popup = buildPopup(feature, this.photos[feature.properties.Photo_Id])
        layer.bindPopup(popup, {maxWidth:500})
        var tooltip = feature.properties.ID === 'N/A' ? feature.properties.Name : feature.properties.ID
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
      window.fetch('data/assets.csv').then(response => response.text())
    ]).then(([photos, facilities, assets]) => {
      this.photos = photos
      markers.addLayer(L.geoCsv(facilities, geoCsvOpts))
      markers.addLayer(L.geoCsv(assets, geoCsvOpts))
    })
  }
}
