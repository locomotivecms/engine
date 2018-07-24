import { combineReducers } from 'redux';

import editor from './editor';
import site from './site';
import page from './page';
import iframe from './iframe';

const rootReducer = combineReducers({
  editor,
  site,
  page,
  iframe
});

export default rootReducer;
