var o = {
  options: {
    hasHeader: true,
    fieldSeparator: ',',
    latitudeTitle: 'lat', // Case sensitive, no mangling or space removal
    longitudeTitle: 'lon', // ditto
    newHeader: ['lat', 'lng', 'popup'] // ignored if hasHeader = true
  },

  addData: function (data) {
    if (typeof data === 'string') {
      var csv = this._dsv(this.options.fieldSeparator)
      var rows
      if (this.options.hasHeader) {
        rows = csv.parse(data)
        // rows will be an array of objects
        this.options.newHeader = rows.columns
      } else {
        rows = csv.parseRows(data)
        // rows will be an array of arrays
      }
      data = this._csv2json(rows)
    }
    // return L.GeoJSON.prototype.addData.call(this, data)
    return data
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
    if (this.options.hasHeader) {
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
      var ilat = this.options.newHeader.indexOf(this.options.latitudeTitle)
      var ilon = this.options.newHeader.indexOf(this.options.longitudeTitle)
      json.features = rows.map(row => {
        var lat = row[ilat]
        var lon = row[ilon]
        // TODO return null if lat/lon is invalid
        var props = {}
        row.forEach((element, i) => {
          if (i !== ilat || i !== ilon) {
            props[this.options.newHeader[i]] = element
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

}
// var text = 'City+Na.me,lat,lon\nLos Angeles,34°03′N,118°15′W\nNew York City,40°42′46″N,74°00′21″W\nParis,48°51′24″N,2°21′03″E'
var text = '"City Na,me",lat,lon\nLos Angeles,34.03,118.15\nNew York City,40.4246,74.0021\nParis,48.5124,2.2103'
var geoJson = o.addData(text)
console.log(geoJson)
geoJson.features.forEach(ele => {
  console.log(ele.geometry)
  console.log(ele.properties)
})

// both parse and parseRows take an optional second argument which is a function that takes
// an array of strings and an optional index number for the row,  The function can filter the
// row (return null), or trtansmogrify the row into an array of typed values. As this is essentially
// tabular data, the number of items in the array, nor the meaning of an item in the array should be changed.
// The following might not be stated correctly.  I.e. all rows with an year as item 0 could return an age ass item 0
// it must be applied to all rows, also a Y,M,D,Hr,Min could be returned as one datetime (header needs fixing)
//
// Test a CSV file without a header, and one with a replaced header
// test with a filter and a map
// test with the default 'autotype' map provided by dsv