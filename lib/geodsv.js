/*
 * Leaflet Plugin to create a GeoDSV Layer - A GeoJSON point layer created from a file of
 *   delimiter-separated values (DSV) with at least two columns for the coordinates of the point.
 *
 * It is assumed that the author of the map has control of the DSV file, therefore no attempt is
 *    made to guess the names of the coordinate columns or sanitaize the values
 * All non-coordinate columns are added to the point as properties using the column name as the key
 * The DSV parser is RFC 4180 (https://tools.ietf.org/html/rfc4180) compliant
 *
 * Adapted from code at
 *   1) https://github.com/joker-x/Leaflet.geoCSV by Iván Eixarch <ivan@sinanimodelucro.org>
 *   2) https://github.com/d3/d3-dsv/blob/master/src/dsv.js
 */

/* global L */

L.GeoDSV = L.GeoJSON.extend({

  options: {
    fieldSeparator: ',',   // Character that delimits values in a line
    firstLineNames: true,  // Does the file have column names in the first line?
    names: ['lat', 'lng', 'popup'], // Names of the columns in the DSV - ignored if firstLineNames = true
    latName: 'Latitude',   // Name of column to use for the point's lat(Y) value - verbatim, case sensitive
    lngName: 'Longitude'   // Name of column to use for the point's lng(X) value - verbatim, case sensitive
  },

  initialize: function (dsv, options) {
    L.Util.setOptions(this, options)
    L.GeoJSON.prototype.initialize.call(this, dsv, options)
  },

  addData: function (data) {
    if (typeof data === 'string') {
      var dsv = this._dsv(this.options.fieldSeparator)
      var rows
      if (this.options.firstLineNames) {
        rows = dsv.parse(data)
        // rows will be an array of objects
        this.options.names = rows.columns
      } else {
        rows = csv.parseRows(data)
        // rows will be an array of arrays
      }
      data = this._dsv2json(rows)
    }
    return L.GeoJSON.prototype.addData.call(this, data)
  },

  _dsv2json: function (rows) {
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
    if (this.options.firstLineNames) {
      json.features = rows.map(element => {
        var lat = element[this.options.latName]
        var lon = element[this.options.lngName]
        // TODO return null if lat/lon is invalid
        var props = Object.assign({}, element)
        delete props[this.options.latName]
        delete props[this.options.lngName]
        return pointFeature(lat, lon, props)
      })
    } else {
      var ilat = this.options.names.indexOf(this.options.latName)
      var ilon = this.options.names.indexOf(this.options.lngName)
      json.features = rows.map(row => {
        var lat = row[ilat]
        var lon = row[ilon]
        // TODO return null if lat/lon is invalid
        var props = {}
        row.forEach((element, i) => {
          if (i !== ilat || i !== ilon) {
            props[this.options.names[i]] = element
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

    // Returns a function that will convert an array into a JSON object with
    // the values in the columns array as keys
    function _objectConverter (columns) {
      /* eslint-disable no-new-func */
      return new Function('d', 'return {' + columns.map(function (name, i) {
        return JSON.stringify(name) + ': d[' + i + '] || ""'
      }).join(',') + '}')
      /* eslint-enable no-new-func */
    }

    // Returns a function that will convert an array into whatever f produces.
    // if f is omitted a JSON object is produced.
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
    // parse:
    // Takes the DSV text and an optional function, f.
    // It parses the text and returns an array of whatever f produces.
    // f takes a default JSON object, row number, and array of
    // column names and returns some new value. The default JSON for a row
    // has each value in the row keyed with the column name.  If f is not
    // provided the default JSON object is returned.
    //
    // parseRows:
    // Takes the DSV text and an optional function, f.
    // It parses the text and returns an array of whatever f produces.
    // f takes the row as an array and the row number and returns some
    // new value.  If f is not provided, an array of arrays is returned.
    }
  }

})

L.geoDSV = function (dsvString, options) {
  return new L.GeoDSV(dsvString, options)
}
