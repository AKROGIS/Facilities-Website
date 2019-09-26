// RFC 4180 CSV Parser
// Extracted from https://github.com/d3/d3-dsv/blob/master/src/dsv.js

var dsv = function(delimiter) {
  var reFormat = new RegExp("[\"" + delimiter + "\n\r]"),
      DELIMITER = delimiter.charCodeAt(0),
      EOL = {},
      EOF = {},
      QUOTE = 34,
      NEWLINE = 10,
      RETURN = 13;

  function _objectConverter(columns) {
    return new Function("d", "return {" + columns.map(function(name, i) {
      return JSON.stringify(name) + ": d[" + i + "] || \"\"";
    }).join(",") + "}");
  }

  function _customConverter(columns, f) {
    var object = _objectConverter(columns);
    return function(row, i) {
      return f(object(row), i, columns);
    };
  }

  function parse(text, f) {
    var convert, columns, rows = parseRows(text, function(row, i) {
      if (convert) return convert(row, i - 1);
      columns = row, convert = f ? _customConverter(row, f) : _objectConverter(row);
    });
    rows.columns = columns || [];
    return rows;
  }

  function parseRows(text, f) {
    var rows = [], // output rows
        N = text.length,
        I = 0, // current character index
        n = 0, // current line number
        t, // current token
        eof = N <= 0, // current token followed by EOF?
        eol = false; // current token followed by EOL?

    // Strip the trailing newline.
    if (text.charCodeAt(N - 1) === NEWLINE) --N;
    if (text.charCodeAt(N - 1) === RETURN) --N;

    function token() {
      if (eof) return EOF;
      if (eol) return eol = false, EOL;

      // Unescape quotes.
      var i, j = I, c;
      if (text.charCodeAt(j) === QUOTE) {
        while (I++ < N && text.charCodeAt(I) !== QUOTE || text.charCodeAt(++I) === QUOTE);
        if ((i = I) >= N) eof = true;
        else if ((c = text.charCodeAt(I++)) === NEWLINE) eol = true;
        else if (c === RETURN) { eol = true; if (text.charCodeAt(I) === NEWLINE) ++I; }
        return text.slice(j + 1, i - 1).replace(/""/g, "\"");
      }

      // Find next delimiter or newline.
      while (I < N) {
        if ((c = text.charCodeAt(i = I++)) === NEWLINE) eol = true;
        else if (c === RETURN) { eol = true; if (text.charCodeAt(I) === NEWLINE) ++I; }
        else if (c !== DELIMITER) continue;
        return text.slice(j, i);
      }

      // Return last token before EOF.
      return eof = true, text.slice(j, N);
    }

    while ((t = token()) !== EOF) {
      var row = [];
      while (t !== EOL && t !== EOF) row.push(t), t = token();
      if (f && (row = f(row, n++)) == null) continue;
      rows.push(row);
    }

    return rows;
  }

  return {
    parse: parse,
    parseRows: parseRows,
  };
}

var csv = dsv(",");

//var text = 'foo,bar\n1,2\na,"b,c"\nregan,"is ""great""!"\n2019-10-01,12:23:45'
var text = 'City+Na.me ,lat,lon\nLos Angeles,34°03′N,118°15′W\nNew York City,40°42′46″N,74°00′21″W\nParis,48°51′24″N,2°21′03″E'
//var text = 'foo,bar\n1,2'
var j = csv.parse(text) // when the first row is a header row
console.log(j) // [ { foo: '1', bar: '2' }, columns: [ 'foo', 'bar' ] ]
//console.log(j.columns)  // 3
//console.log(j.length)  // [ { foo: '1', bar: '2' }, columns: [ 'foo', 'bar' ] ]
//console.log(j[0].City)  // [ { foo: '1', bar: '2' }, columns: [ 'foo', 'bar' ] ]
//console.log(j[0][])
//var j = csv.parseRows(text) // when the first row is data
//console.log(j)  // [ [ 'foo', 'bar' ], [ '1', '2' ] ]
