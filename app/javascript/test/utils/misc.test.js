import { expect } from 'chai';
import { arrayMove, isBlank, presence, stripHTML } from '../../src/locomotive/editor/utils/misc';

describe('locomotive/editor/utils/misc', function() {

  describe('#stripHTML', function() {

    it('should strip all the HTML tags of a string', function() {
      expect(stripHTML('<b>Hello</b> world')).to.eql('Hello world');
    });

    it('should remove all the \n and \t occurences of a string', function() {
      expect(stripHTML("\tHello\n\nworld")).to.eql('Hello world');
    });

    it('should remove all the &nbsp; and &amp; occurences of a string', function() {
      expect(stripHTML("\tHello&nbsp;&nbsp; &amp;&nbsp;world")).to.eql('Hello & world');
    });

    it('should return null if the HTML string is null', function() {
      expect(stripHTML(null)).to.eql(null);
    });

  });

  describe('#isBlank()', function() {

    it('should return true if the object is an empty string', function() {
      expect(isBlank('')).to.eql(true);
    });

    it('should return true if the object is an empty array', function() {
      expect(isBlank([])).to.eql(true);
    });

    it('should return true if the object is null', function() {
      expect(isBlank(null)).to.eql(true);
    });

    it('should return true if the object is undefined', function() {
      expect(isBlank(undefined)).to.eql(true);
    });

  });

  describe('#presence()', function() {

    it('should return the object itself it is not blank', function() {
      expect(presence('Hello world')).to.eql('Hello world');
    });

    it('should return false if the the object is blank', function() {
      expect(presence('')).to.eql(null);
    });

  });

  describe('#arrayMove()', function() {

    it('should return the same array if newIndex and oldIndex are the same', function() {
      expect(arrayMove(['a', 'b', 'c'], 0, 0)).to.eql(['a', 'b', 'c']);
    });

    it('should return a new array with the updated positions (oldIndex > newIndex)', function() {
      expect(arrayMove(['a', 'b', 'c'], 1, 0)).to.eql(['b', 'a', 'c']);
      expect(arrayMove(['a', 'b', 'c'], 2, 0)).to.eql(['c', 'a', 'b']);
      expect(arrayMove(['a', 'b', 'c'], 2, 1)).to.eql(['a', 'c', 'b']);
      expect(arrayMove(['a', 'b', 'c', 'd'], 2, 0)).to.eql(['c', 'a', 'b', 'd']);
      expect(arrayMove(['a', 'b', 'c', 'd'], 3, 0)).to.eql(['d', 'a', 'b', 'c']);
    });

    it('should return a new array with the updated positions (oldIndex < newIndex)', function() {
      expect(arrayMove(['a', 'b', 'c'], 0, 1)).to.eql(['b', 'a', 'c']);
      expect(arrayMove(['a', 'b', 'c'], 0, 2)).to.eql(['b', 'c', 'a']);
      expect(arrayMove(['a', 'b', 'c'], 1, 2)).to.eql(['a', 'c', 'b']);
      expect(arrayMove(['a', 'b', 'c', 'd'], 0, 2)).to.eql(['b', 'c', 'a', 'd']);
      expect(arrayMove(['a', 'b', 'c', 'd'], 0, 3)).to.eql(['b', 'c', 'd', 'a']);
    });

  });
});
