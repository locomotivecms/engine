import { createStore, compse } from 'redux';
import rootReducer from './reducers/index.js';

// create an object for the default data
const { site, page, sectionDefinitions } = window.Locomotive.data;
const defaultState = {
  site,
  page,
  sectionDefinitions,
  iframe: {
    loaded:     false,
    window:     null
  }
};


const store = createStore(
  rootReducer,
  defaultState,
  window.__REDUX_DEVTOOLS_EXTENSION__ && window.__REDUX_DEVTOOLS_EXTENSION__()
);


export default store;
