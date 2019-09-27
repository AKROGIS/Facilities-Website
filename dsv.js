// RFC 4180 CSV Parser
// Extracted from https://github.com/d3/d3-dsv/blob/master/src/dsv.js

var dsv = function (delimiter) {
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

function autoType(object) {
  // https://github.com/d3/d3-dsv/issues/45
  var fixtz = new Date("2019-01-01T00:00").getHours() || new Date("2019-07-01T00:00").getHours();

  for (var key in object) {
    var value = object[key].trim(), number, m;
    if (!value) value = null;
    else if (value === "true") value = true;
    else if (value === "false") value = false;
    else if (value === "NaN") value = NaN;
    else if (!isNaN(number = +value)) value = number;
    else if (m = value.match(/^([-+]\d{2})?\d{4}(-\d{2}(-\d{2})?)?(T\d{2}:\d{2}(:\d{2}(\.\d{3})?)?(Z|[-+]\d{2}:\d{2})?)?$/)) {
      if (fixtz && !!m[4] && !m[7]) value = value.replace(/-/g, "/").replace(/T/, " ");
      value = new Date(value);
    }
    else continue;
    object[key] = value;
  }
  return object;
}

// Test 1
/*
var csv = dsv(',')
var text = 'foo,bar\n1,2'
var r1 = csv.parse(text)
console.log(r1)
// expect: [ { foo: '1', bar: '2' }, columns: [ 'foo', 'bar' ] ]
console.log(r1.columns)
// expect: [ 'foo', 'bar' ]
console.log(r1.length)
// expect: 1
console.log(r1[0].bar)
// expect: 2
var r2 = csv.parseRows(text)
console.log(r2)
// expect: [ [ 'foo', 'bar' ], [ '1', '2' ] ]
console.log(r2.columns)
// expect: undefined
console.log(r2.length)
// expect: 2
console.log(r2[0].bar)
// expect: undefined
console.log(r2[1][1])
// expect: 2
*/
// Test 2
var text = 'foo,bar\n1,2\n3.14151926,-0.123\nab \u263A de,abc\ntrue,false\n,null\na,"b,c"\n"dsv","is\n""great""!"\n2019-10-01,12:23:45'
console.log(dsv(',').parse(text, autoType))
// expect: [ { foo: '1', bar: '2' }, { foo: 'a', bar: 'b,c' }, { foo: 'regan', bar: 'is "great"!' }, { foo: '2019-10-01', bar: '12:23:45' }, columns: [ 'foo', 'bar' ]]
// Test 3
/*
var text = 'City+Na.me ,lat,lon\nLos Angeles,34°03′N,118°15′W\nNew York City,40°42′46″N,74°00′21″W\nParis,48°51′24″N,2°21′03″E'
console.log(dsv(',').parse(text))
*/
