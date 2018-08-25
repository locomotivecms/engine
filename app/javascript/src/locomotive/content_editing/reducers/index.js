import { combineReducers } from 'redux';

import editor from './editor';
import content from './content';
import site from './site';
import page from './page';
import iframe from './iframe';

const rootReducer = combineReducers({
  editor,
  content,
  site,
  page,
  iframe
});

export default rootReducer;
