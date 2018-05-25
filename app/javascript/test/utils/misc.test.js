// import assert from 'assert';
import { expect } from 'chai';
import { arrayMove } from '../../src/locomotive/content_editing/utils/misc';

describe('locomotive/editor/utils/misc', function() {

  describe('#arrayMove()', function() {

    it('should return the same array if newIndex and oldIndex are the same', function() {
      expect(arrayMove(['a', 'b', 'c'], 0, 0)).to.eql(['a', 'b', 'c']);
    });

    it('should return a new array with the updated positions (oldIndex > newIndex)', function() {
      expect(arrayMove(['a', 'b', 'c'], 1, 0)).to.eql(['b', 'a', 'c']);
      expect(arrayMove(['a', 'b', 'c'], 2, 0)).to.eql(['c', 'a', 'b']);
      expect(arrayMove(['a', 'b', 'c'], 2, 1)).to.eql(['a', 'c', 'b']);
      expect(arrayMove(['a', 'b', 'c', 'd'], 2, 0)).to.eql(['c', 'a', 'b', 'd']);
    });

    it('should return a new array with the updated positions (oldIndex < newIndex)', function() {
      expect(arrayMove(['a', 'b', 'c'], 0, 1)).to.eql(['b', 'a', 'c']);
      expect(arrayMove(['a', 'b', 'c'], 0, 2)).to.eql(['c', 'a', 'b']);
      expect(arrayMove(['a', 'b', 'c'], 1, 2)).to.eql(['a', 'c', 'b']);
      expect(arrayMove(['a', 'b', 'c', 'd'], 0, 2)).to.eql(['c', 'a', 'b', 'd']);
    });

  });
});
