import React from 'react';
import Enzyme, { shallow } from 'enzyme';
import { connect } from 'react-redux';
import * as redux from 'redux';
import Adapter from 'enzyme-adapter-react-16';
import { expect } from 'chai';
import { Route } from 'react-router';

import { Main } from '../../../javascript/src/locomotive/content_editing/views/main.jsx'; //should put in tests utils
import Startup from '../../../javascript/src/locomotive/content_editing/views/startup.jsx'; //should put in tests utils

import { buildProps } from '../utils'
Enzyme.configure({ adapter: new Adapter() });

const prettyFormat = require('pretty-format')

describe('components', () => {
  describe('Main', () => {
    describe('render', () => {
      it('should render an action bar', () => {
        const props = buildProps();
        const subject = shallow(<Main { ...props } />);
        expect(subject.find('.actionbar').length).to.equal(1);
      });

      describe('when preview is not loaded yet', () => {
        it('should render a waiting screen', () => {
          const props = buildProps();
          const subject = shallow(<Main { ...props } />);
          expect(subject).to.contains(Startup);
        });
      });

      describe('when preview is loaded', () => {
        it('should defined Routes on /', () => {
          const props = buildProps({iframe: { loaded: true, window: null }});
          const subject = shallow(<Main { ...props } />);
          expect(subject.find(Route)).to.exist;
          expect(subject.find(Route).findWhere(n => n.props().path == '/')).to.exist;
        });
      });
    });
  })
})




