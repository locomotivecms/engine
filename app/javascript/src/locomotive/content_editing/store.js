import { createStore, applyMiddleware } from 'redux';
import thunk from 'redux-thunk';
import rootReducer from './reducers/index';

import ApiFactory from './services/api';

// create an object for the default data
const { data, urls } = window.Locomotive;
const { site, page, sectionDefinitions, sections, editableElements } = data;

const defaultState = {
  editor: {
    sectionDefinitions,
    sections,
    editableElements,
    urls,
    api: ApiFactory(urls)
  },
  site,
  page,
  iframe: {
    loaded: false,
    window: null
  }
};

export default createStore(
  rootReducer,
  defaultState,
  applyMiddleware(thunk),
  window.__REDUX_DEVTOOLS_EXTENSION__ && window.__REDUX_DEVTOOLS_EXTENSION__()
);
