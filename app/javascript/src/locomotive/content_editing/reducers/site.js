import update from 'immutability-helper';
import { findIndex } from 'lodash';

function site(state = {}, action) {
  switch(action.type) {

    case 'STATIC_SECTION::UPDATE_INPUT':
      return update(state, {
        sectionsContent: {
          [action.sectionType]: {
            settings: {
              [action.id]: { $set: action.newValue }
            }
          }
        }
      });

    case 'STATIC_SECTION::ADD_BLOCK':
      return update(state, {
        sectionsContent: {
          [action.sectionType]: {
            blocks: { $push: [action.newBlock] }
          }
        }
      });

    case 'STATIC_SECTION::REMOVE_BLOCK':
      const blocks = state.sectionsContent[action.sectionType].blocks;
      const index  = findIndex(blocks, block => block.id === action.blockId);

      return update(state, {
        sectionsContent: {
          [action.sectionType]: {
            blocks: { $splice: [[index, 1]] }
          }
        }
      });

    default:
      return state;
  }
}

export default site;
