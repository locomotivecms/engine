import { combineReducers } from 'redux';

import site from './site';
import page from './page';
import sectionDefinitions from './section_definitions';
import iframe from './iframe';
import view from './view';

const rootReducer = combineReducers({
  site,
  page,
  sectionDefinitions,
  iframe,
  view
});

export default rootReducer;
