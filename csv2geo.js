/*
 * Adapted from code at
 * 1) https://github.com/joker-x/Leaflet.geoCSV by Iván Eixarch <ivan@sinanimodelucro.org>
 * 2) https://github.com/d3/d3-dsv/blob/master/src/dsv.js
 */

/* global L */

L.GeoCSV = L.GeoJSON.extend({

  options: {
    firstLineTitles: true,
    fieldSeparator: ',',
    latitudeTitle: 'latitude', // Case sensitive, no mangling or space removal
    longitudeTitle: 'longitude', // ditto
    titles: ['lat', 'lng', 'popup'] // ignored if firstLineTitles = true
  },

  initialize: function (csv, options) {
    L.Util.setOptions(this, options)
    L.GeoJSON.prototype.initialize.call(this, csv, options)
  },

  addData: function (data) {
    if (typeof data === 'string') {
      var csv = this._dsv(this.options.fieldSeparator)
      var rows
      if (this.options.firstLineTitles) {
        rows = csv.parse(data)
        // rows will be an array of objects
        this.options.titles = rows.columns
      } else {
        rows = csv.parseRows(data)
        // rows will be an array of arrays
      }
      data = this._csv2json(rows)
    }
    return L.GeoJSON.prototype.addData.call(this, data)
  },

  _csv2json: function (rows) {
    function pointFeature (lat, lon, props) {
      return {
        type: 'Feature',
        geometry: {
          type: 'Point',
          coordinates: [lon, lat]
        },
        properties: props
      }
    }
    var json = {
      type: 'FeatureCollection'
    }
    if (this.options.firstLineTitles) {
      json.features = rows.map(element => {
        var lat = element[this.options.latitudeTitle]
        var lon = element[this.options.longitudeTitle]
        // TODO return null if lat/lon is invalid
        var props = Object.assign({}, element)
        delete props[this.options.latitudeTitle]
        delete props[this.options.longitudeTitle]
        return pointFeature(lat, lon, props)
      })
    } else {
      var ilat = this.options.titles.indexOf(this.options.latitudeTitle)
      var ilon = this.options.titles.indexOf(this.options.longitudeTitle)
      json.features = rows.map(row => {
        var lat = row[ilat]
        var lon = row[ilon]
        // TODO return null if lat/lon is invalid
        var props = {}
        row.forEach((element, i) => {
          if (i !== ilat || i !== ilon) {
            props[this.options.titles[i]] = element
          }
        })
        return pointFeature(lat, lon, props)
      })
    }
    return json
  },

  _dsv: function (delimiter) {
    var DELIMITER = delimiter.charCodeAt(0)
    var EOL = {}
    var EOF = {}
    var QUOTE = 34
    var NEWLINE = 10
    var RETURN = 13

    function _objectConverter (columns) {
      /* eslint-disable no-new-func */
      return new Function('d', 'return {' + columns.map(function (name, i) {
        return JSON.stringify(name) + ': d[' + i + '] || ""'
      }).join(',') + '}')
      /* eslint-enable no-new-func */
    }

    function _customConverter (columns, f) {
      var object = _objectConverter(columns)
      return function (row, i) {
        return f(object(row), i, columns)
      }
    }

    function parse (text, f) {
      var convert
      var columns
      var rows = parseRows(text, function (row, i) {
        if (convert) return convert(row, i - 1)
        columns = row
        convert = f ? _customConverter(row, f) : _objectConverter(row)
      })
      rows.columns = columns || []
      return rows
    }

    function parseRows (text, f) {
      var rows = [] // output rows
      var N = text.length
      var I = 0 // current character index
      var n = 0 // current line number
      var t // current token
      var eof = N <= 0 // current token followed by EOF?
      var eol = false // current token followed by EOL?

      // Strip the trailing newline.
      if (text.charCodeAt(N - 1) === NEWLINE) --N
      if (text.charCodeAt(N - 1) === RETURN) --N

      function token () {
        if (eof) return EOF
        if (eol) {
          eol = false
          return EOL
        }

        // Unescape quotes.
        var i
        var j = I
        var c
        if (text.charCodeAt(j) === QUOTE) {
          while ((I++ < N && text.charCodeAt(I) !== QUOTE) || text.charCodeAt(++I) === QUOTE) /* empty */ ;
          if ((i = I) >= N) eof = true
          else if ((c = text.charCodeAt(I++)) === NEWLINE) eol = true
          else if (c === RETURN) {
            eol = true
            if (text.charCodeAt(I) === NEWLINE) ++I
          }
          return text.slice(j + 1, i - 1).replace(/""/g, '"')
        }

        // Find next delimiter or newline.
        while (I < N) {
          if ((c = text.charCodeAt(i = I++)) === NEWLINE) eol = true
          else if (c === RETURN) {
            eol = true
            if (text.charCodeAt(I) === NEWLINE) ++I
          } else if (c !== DELIMITER) continue
          return text.slice(j, i)
        }

        // Return last token before EOF.
        eof = true
        return text.slice(j, N)
      }

      while ((t = token()) !== EOF) {
        var row = []
        while (t !== EOL && t !== EOF) {
          row.push(t)
          t = token()
        }
        if (f && (row = f(row, n++)) == null) continue
        rows.push(row)
      }

      return rows
    }

    return {
      parse: parse,
      parseRows: parseRows
    }
  }

})

L.geoCsv = function (csvString, options) {
  return new L.GeoCSV(csvString, options)
}
