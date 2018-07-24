import update from '../utils/immutable_update';
import { findIndex } from 'lodash';

function findBlockIndex(state, action) {
  const blocks = state.sectionsContent[action.sectionType].blocks;
  return findIndex(blocks, block => block.id === action.blockId);
}

function site(state = {}, action) {
  switch(action.type) {

    case 'CONTENT::LOAD':
      return action.site;

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

    case 'STATIC_SECTION::BLOCK::ADD':
      return update(state, {
        sectionsContent: {
          [action.sectionType]: {
            blocks: { $push: [action.newBlock] }
          }
        }
      });

    case 'STATIC_SECTION::BLOCK::MOVE':
      return update(state, {
        sectionsContent: {
          [action.sectionType]: {
            blocks: {
              $arrayMove: {
                oldIndex: action.oldIndex,
                newIndex: action.newIndex
              }
            }
          }
        }
      });

    case 'STATIC_SECTION::BLOCK::REMOVE':
      return update(state, {
        sectionsContent: {
          [action.sectionType]: {
            blocks: { $splice: [[findBlockIndex(state, action), 1]] }
          }
        }
      });

    case 'STATIC_SECTION::BLOCK::UPDATE_INPUT':
      return update(state, {
        sectionsContent: {
          [action.sectionType]: {
            blocks: {
              [findBlockIndex(state, action)]: {
                settings: {
                  [action.id]: { $set: action.newValue }
                }
              }
            }
          }
        }
      });

    default:
      return state;
  }
}

export default site;
