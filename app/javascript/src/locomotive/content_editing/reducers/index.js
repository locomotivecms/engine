import { combineReducers } from 'redux';

import site from './site';
import page from './page';
import iframe from './iframe';

const rootReducer = combineReducers({
  site,
  page,
  iframe
});

export default rootReducer;
