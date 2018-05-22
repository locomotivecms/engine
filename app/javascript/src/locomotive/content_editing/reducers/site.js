import update from 'immutability-helper';
import { findIndex } from 'lodash';

function site(state = {}, action) {
  // console.log('SITE', state, action);

  switch(action.type) {
    case 'PERSIST_CHANGES':
      // console.log('SITE', 'PERSIST_CHANGES', state);
      return state;

    case 'EDIT_SECTION_INPUT':
      if (!action.static) return state;
      // const index = findIndex(state.sectionsContent, section => { return section.type === action.sectionType })

      // console.log('TODO: UPDATE SECTION INPUT', action, state, index);

      return update(state, {
        sectionsContent: {
          [action.sectionType]: {
            settings: {
              [action.id]: { $set: action.newValue }
            }
          }
        }
      });

    default:
      return state;
  }
}

export default site;
