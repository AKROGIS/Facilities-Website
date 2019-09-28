/* global L, expect, afterEach, beforeEach, describe, it */
/* eslint-disable no-unused-expressions */

describe('dsv.js', function () {
  describe('parse csv with header', function () {
    var csv = dsv(',')
    describe('with newline (unix) line endings', function () {
      var text = 'foo,bar\n1,2\n'
      var rows = csv.parse(text)
      it('returns an array of 1 objects', function () {
        expect(rows).is.a('array');
        expect(rows.length).to.equal(1);
        expect(rows[0]).is.a('object');
      });
      it('creates the correct columns property', function () {
        expect(rows.columns).to.deep.equal(['foo','bar']);
      });
      it('first row is as expected', function () {
        expect(rows[0]).to.deep.equal({foo:'1', bar:'2'})
      });
    });
    describe('with cr-nl (windows) line endings', function () {
      var text = 'foo,bar\r\n1,2\r\n'
      var rows = csv.parse(text)
      it('returns an array of 1 objects', function () {
        expect(rows).is.a('array');
        expect(rows.length).to.equal(1);
        expect(rows[0]).is.a('object');
      });
      it('creates the correct columns property', function () {
        expect(rows.columns).to.deep.equal(['foo','bar']);
      });
      it('first row is as expected', function () {
        expect(rows[0]).to.deep.equal({foo:'1', bar:'2'})
      });
    });
    describe('with no newline at end of file', function () {
      var text = 'foo,bar\n1,2'
      var rows = csv.parse(text)
      it('returns an array of 1 objects', function () {
        expect(rows).is.a('array');
        expect(rows.length).to.equal(1);
        expect(rows[0]).is.a('object');
      });
      it('creates the correct columns property', function () {
        expect(rows.columns).to.deep.equal(['foo','bar']);
      });
      it('first row is as expected', function () {
        expect(rows[0]).to.deep.equal({foo:'1', bar:'2'})
      });
    });
    describe('with spaces before and after separater (spaces are significant', function () {
      var text = ' foo , bar \n 1 , 2 '
      var rows = csv.parse(text)
      it('returns an array of 1 objects', function () {
        expect(rows).is.a('array');
        expect(rows.length).to.equal(1);
        expect(rows[0]).is.a('object');
      });
      it('creates the correct columns property', function () {
        expect(rows.columns).to.deep.equal([' foo ',' bar ']);
      });
      it('first row is as expected', function () {
        expect(rows[0]).to.have.property(' foo ', ' 1 ');
        expect(rows[0]).to.have.property(' bar ', ' 2 ');
      });
    });
    describe('with quoted fields', function () {
      var text = '"foo","bar"\n"1","2"'
      var rows = csv.parse(text)
      it('returns an array of 1 objects', function () {
        expect(rows).is.a('array');
        expect(rows.length).to.equal(1);
        expect(rows[0]).is.a('object');
      });
      it('creates the correct columns property', function () {
        expect(rows.columns).to.deep.equal(['foo','bar']);
      });
      it('first row is as expected', function () {
        expect(rows[0]).to.deep.equal({foo:'1', bar:'2'})
      });
    });
    describe('with delimeter in quoted fields', function () {
      var text = '"foo,foo","bar"\n"1,a","2"\n'
      var rows = csv.parse(text)
      it('returns an array of 1 objects', function () {
        expect(rows).is.a('array');
        expect(rows.length).to.equal(1);
        expect(rows[0]).is.a('object');
      });
      it('creates the correct columns property', function () {
        expect(rows.columns).to.deep.equal(['foo,foo','bar']);
      });
      it('first row is as expected', function () {
        expect(rows[0]).to.have.property('foo,foo', '1,a');
        expect(rows[0]).to.have.property('bar', '2');
      });
    });
    describe('with quote in quoted fields', function () {
      var text = '"foo""foo",bar\n"1""a",2\n'
      var rows = csv.parse(text)
      it('returns an array of 1 objects', function () {
        expect(rows).is.a('array');
        expect(rows.length).to.equal(1);
        expect(rows[0]).is.a('object');
      });
      it('creates the correct columns property', function () {
        expect(rows.columns).to.deep.equal(['foo"foo','bar']);
      });
      it('first row is as expected', function () {
        expect(rows[0]).to.have.property('foo"foo', '1"a');
        expect(rows[0]).to.have.property('bar', '2');
      });
    });
    describe('with unix escape code (\\) in unquoted fields', function () {
      var text = 'fo\o,b\ar\n\1,\2\n'
      var rows = csv.parse(text)
      it('returns an array of 1 objects', function () {
        expect(rows).is.a('array');
        expect(rows.length).to.equal(1);
        expect(rows[0]).is.a('object');
      });
      it('creates the correct columns property', function () {
        expect(rows.columns).to.deep.equal(['fo\o','b\ar']);
      });
      it('first row is as expected', function () {
        expect(rows[0]).to.have.property('fo\o', '\1');
        expect(rows[0]).to.have.property('b\ar', '\2');
      });
    });
  });
  describe('parse csv without header (parseRows)', function () {
    var csv = dsv(',')
    describe('with newline (unix) line endings', function () {
      // parse() tested above calls parseRows(), so all the above tests apply to parseRows() as well
      var text = 'foo,bar\n1,2\n'
      var rows = csv.parseRows(text)
      it('returns an array of 2 arrays', function () {
        expect(rows).is.a('array');
        expect(rows.length).to.equal(2);
        expect(rows[0]).is.a('array');
      });
      it('has no columns property', function () {
        expect(rows).to.not.have.property('columns');
      });
      it('first row is as expected', function () {
        expect(rows[0]).to.deep.equal(['foo', 'bar'])
      });
      it('second row is as expected', function () {
        expect(rows[1]).to.deep.equal(['1', '2'])
      });
    });
  });
  describe('parse tsv with header', function () {
    var csv = dsv('\t')
    describe('with newline (unix) line endings', function () {
      var text = 'foo\tbar\n1\t2\n'
      var rows = csv.parse(text)
      it('returns an array of 1 objects', function () {
        expect(rows).is.a('array');
        expect(rows.length).to.equal(1);
        expect(rows[0]).is.a('object');
      });
      it('creates the correct columns property', function () {
        expect(rows.columns).to.deep.equal(['foo','bar']);
      });
      it('first row is as expected', function () {
        expect(rows[0]).to.deep.equal({foo:'1', bar:'2'})
      });
    });
  });
  describe('parse |sv (pipe separted values) with header', function () {
    var csv = dsv('|')
    describe('with newline (unix) line endings', function () {
      var text = 'foo|bar\n1|2\n'
      var rows = csv.parse(text)
      it('returns an array of 1 objects', function () {
        expect(rows).is.a('array');
        expect(rows.length).to.equal(1);
        expect(rows[0]).is.a('object');
      });
      it('creates the correct columns property', function () {
        expect(rows.columns).to.deep.equal(['foo','bar']);
      });
      it('first row is as expected', function () {
        expect(rows[0]).to.deep.equal({foo:'1', bar:'2'})
      });
    });
  });
});

// Test autoType
// var text = 'foo,bar\n1,2\n3.14151926,-0.123\nab \u263A de,abc\ntrue,false\n,null\na,"b,c"\n"dsv","is\n""great""!"\n2019-10-01,12:23:45'
// console.log(dsv(',').parse(text, autoType))
// var text = 'City+Na.me ,lat,lon\nLos Angeles,34°03′N,118°15′W\nNew York City,40°42′46″N,74°00′21″W\nParis,48°51′24″N,2°21′03″E'

// Test custom filter and map
