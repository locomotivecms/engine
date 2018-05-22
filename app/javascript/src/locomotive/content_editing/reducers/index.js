import { combineReducers } from 'redux';

import site from './site.js';
import page from './page.js';
import sectionDefinitions from './section_definitions.js';

const rootReducer = combineReducers({
  site,
  page,
  sectionDefinitions
});

export default rootReducer;
