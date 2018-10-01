import { combineReducers } from 'redux';

import editor from './editor';
import content from './content';
import iframe from './iframe';

const rootReducer = combineReducers({
  editor,
  content,
  iframe
});

export default rootReducer;
