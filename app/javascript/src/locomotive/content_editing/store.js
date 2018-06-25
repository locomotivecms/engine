import { createStore, compse } from 'redux';
import rootReducer from './reducers/index.js';

// create an object for the default data
const { site, page } = window.Locomotive.data;
const defaultState = {
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
  window.__REDUX_DEVTOOLS_EXTENSION__ && window.__REDUX_DEVTOOLS_EXTENSION__()
);
