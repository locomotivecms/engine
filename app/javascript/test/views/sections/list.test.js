import React from 'react';
import Enzyme, { shallow } from 'enzyme';
import Adapter from 'enzyme-adapter-react-16';
import * as redux from 'redux'
import { connect } from 'react-redux';

import { Index } from '../../../../javascript/src/locomotive/editor/views/sections/list'; //should put in tests utils
import SimpleList from '../../../../javascript/src/locomotive/editor/views/sections/list/simple';
import Dropzone from '../../../../javascript/src/locomotive/editor/views/sections/list/dropzone';
import { buildProps } from '../../utils'

Enzyme.configure({ adapter: new Adapter() });

describe('components', () => {
  describe('Index', () => {
    describe('render', () => {
      describe('without dropzone', () => {

        it("shouldn't render a static list of sections if none", () => {
          const props = buildProps();

          const wrapper = shallow(<Index { ...props } />);

          expect(wrapper.find(SimpleList).length).toBe(0)
          expect(wrapper.find(Dropzone).length).toBe(0)

        });

        describe('with sections', () => {
          it('should render a static list with good data', () => {
            const props = buildProps({ sections: { top: ['header'], bottom: ['footer'] } });
            const wrapper = shallow(<Index { ...props } />);
            expect(wrapper.find(SimpleList).length).toBe(2)
          });
        });

      });

      describe('with dropzone', () => {
        it('should render a list', () => {
          const props = buildProps({ sections: { top: [], bottom: [], dropzone: true }, dropzoneContent: [{ name: 'Slider' }] });

          const wrapper = shallow(<Index { ...props } />);

          expect(wrapper.find(Dropzone).length).toBe(1)
          expect(wrapper.find(SimpleList).length).toBe(0)
        });

        describe('with top and bottom sections', () => {
          it('should render a static list on top', () => {
            const props = buildProps({sections: { top: ['header'], bottom: ['footer'], dropzone: true }, dropzoneContent: [{ name: 'Slider' }] });
            const wrapper = shallow(<Index { ...props } />);

            expect(wrapper.find(Dropzone).length).toBe(1)
            expect(wrapper.find(SimpleList).length).toBe(2)
          });
        });
      });
    });
  })
})
