import React from 'react';
import Enzyme, { shallow } from 'enzyme';
import Adapter from 'enzyme-adapter-react-16';
import * as redux from 'redux'
import { connect } from 'react-redux';

import Index from '../../../../javascript/src/locomotive/content_editing/views/sections/index.jsx'; //should put in tests utils
import StaticList from '../../../../javascript/src/locomotive/content_editing/views/sections/components/static_list.jsx';
import List from '../../../../javascript/src/locomotive/content_editing/views/sections/components/list.jsx';
import Startup from '../../../../javascript/src/locomotive/content_editing/views/startup.jsx'; //should put in tests utils

Enzyme.configure({ adapter: new Adapter() });

const prettyFormat = require('pretty-format')

function buildProps(specificPropsHash) {
  let sections = {
    "all": undefined,
    "top": undefined,
    "dropzone": undefined,
    "bottom": undefined
  }

  let editableElements = undefined

  const props = {
    site: undefined,
    page: undefined,
    editableElements,
    sections,
    sectionDefinitions: undefined,
    iframe: {
      loaded:     false,
      window:     null
    }
  };

  return { ...props, ...specificPropsHash };
}

describe('components', () => {
  describe('Index', () => {
    describe('render', () => {
      describe('without dropzone', () => {
        it('should render a static list', () => {
          const props = buildProps();
          const wrapper = shallow(<Index { ...props } />);

          expect(wrapper.contains(<StaticList />)).toBe(true)
          expect(wrapper.find(StaticList).length).toBe(1)
          expect(wrapper.find(List).length).toBe(0)
          expect(wrapper.find(StaticList).first().prop('all')).toBe(undefined)

        });
        describe('with sections', () => {
          it('should render a static list with good datas', () => {
            const props = buildProps({sections: {all: ['header', 'footer']}});
            const wrapper = shallow(<Index { ...props } />);
            expect(wrapper.contains(<StaticList list={['header', 'footer']} />)).toBe(true)
          });
        });
      });

      describe('with dropzone', () => {
        it('should render a list', () => {
          const props = buildProps({sections: {'top': [], 'bottom': [], 'dropzone': true}});

          const wrapper = shallow(<Index { ...props } />);

          expect(wrapper.contains(<List />)).toBe(true)
          expect(wrapper.find(List).length).toBe(1)
          expect(wrapper.find(StaticList).length).toBe(0)
        });

        describe('with top and bottom sections', () => {
          it('should render a static list on top', () => {
            const props = buildProps({sections: {'all': ['header', 'footer'], 'top': ['header'], 'dropzone': true, 'bottom': ['footer']}});
            const wrapper = shallow(<Index { ...props } />);
            expect(wrapper.find(List).length).toBe(1)
            expect(wrapper.contains(<StaticList list={['footer']} />)).toBe(true)

            expect(wrapper.contains(<StaticList list={['header']} />)).toBe(true)
            expect(wrapper.find(StaticList).length).toBe(2)
          });
        });


      //   it('should render a List of non static sections', () => {
      //     const props = buildProps();
      //     const subject = shallow(<Index { ...props } />);
      //     expect(subject).to.contains(List)

      //   });
      });
    });
  })
})
