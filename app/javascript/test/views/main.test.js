import React from 'react';
import Enzyme, { shallow } from 'enzyme'; // https://www.jonathan-petitcolas.com/2017/10/31/learning-jest-through-practice.html
import { connect } from 'react-redux'; //https://redux.js.org/recipes/writing-tests#connected-components
import * as redux from 'redux' //wtf? https://stackoverflow.com/questions/41693005/mock-redux-saga-middleware-with-jest
import Adapter from 'enzyme-adapter-react-16';
import { expect } from 'chai';
import { Route } from 'react-router';

// Note the curly braces: grab the named export instead of default export see https://redux.js.org/recipes/writing-tests
import { Main } from '../../../javascript/src/locomotive/content_editing/views/main.jsx'; //should put in tests utils
import Startup from '../../../javascript/src/locomotive/content_editing/views/startup.jsx'; //should put in tests utils

Enzyme.configure({ adapter: new Adapter() });

const prettyFormat = require('pretty-format')


function buildProps(specificPropsHash) {
  redux.createStore = jest.fn();
  let sections = {
    "all": [],
    "top": [],
    "bottom": [],
    "dropzone": []
  }

  let editableElements = []

  const props = {
    site: undefined,
    page: undefined,
    editableElements,
    sections,
    sectionDefinitions: jest.fn(),
    iframe: {
      loaded:     false,
      window:     null
    }
  };

  return { ...props, ...specificPropsHash };
}

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
        it('should render a home on /', () => {
          const props = buildProps({iframe: { loaded: true, window: null }});
          const subject = shallow(<Main { ...props } />);
          expect(subject.find(Route)).to.exist;
          const rootComponent = subject.find(Route).findWhere(n => n.props().path == '/');
          //Todo how to check home rendering ?
        });
      });
    });
  })
})




