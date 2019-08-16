/**
 * Created by regan_sarwas on 7/8/14.
 * Replaced GINA BDL with Esri Imagery 7/10/17.
 * Update the URL to the building footprints on 11/26/2018.
 */
var NPMap = {
    center: {
        lat: 62,
        lng: -152
    },
    div: 'map',
    overlays: [
      {
        cluster: true,
        popup: {
            title: '{{ID}}',
            description: '<p>{{Name}}</p>' +
            '<table>' +
                '<tr><td class="att_name">Description</td><td>{{Desc}}</td></tr>' +
                '<tr><td class="att_name">Value</td><td>{{CRV}}</td></tr>' +
                '<tr><td class="att_name">Def. Maint</td><td>{{DM}}</td></tr>' +
                '<tr><td class="att_name">Age</td><td>{{Age}}</td></tr>' +
                '<tr><td class="att_name">Status</td><td>{{Status}}</td></tr>' +
                '</table>',
            media:[{
                type:"fmss",
                id:"Photo_Id"
            }]
        },
        styles: {
          point: {
              'marker-symbol': 'square'
          }
        },
        tooltip: '{{ID}}',
        type: 'csv',
        url: 'data/facilities.csv'
      }
      ,{
        type:'arcgisserver',
        opacity: 1.0,
        tiled: false,
        minZoom:15,
        url: 'https://akrgis.nps.gov/arcgis/rest/services/AKR_Apps/FMSS_web_service/MapServer'
      }
     ,{
        type: 'arcgisserver',
        opacity: 0.8,
        tiled: true,
        url: 'https://services.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer',
        minZoom:15,
        popup: '{{Name}}'
      }
    ],
    zoom: 5,
    maxZoom: 20
};
