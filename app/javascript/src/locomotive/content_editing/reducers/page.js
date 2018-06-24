import update from '../utils/immutable_update';
import { findIndex } from 'lodash';

function findSectionIndex(state, action) {
  const sections = state.sectionsContent;
  return findIndex(sections, section => section.id === action.sectionId);
}

function findBlockIndex(sectionIndex, state, action) {
  const blocks = state.sectionsContent[sectionIndex].blocks;
  return findIndex(blocks, block => block.id === action.blockId);
}

function page(state = [], action) {
  var sectionIndex = null, blockIndex = null;

  switch(action.type) {

    // SECTIONS

    case 'SECTION::UPDATE_INPUT':
      return update(state, {
        sectionsContent: {
          [findSectionIndex(state, action)]: {
            settings: {
              [action.id]: { $set: action.newValue }
            }
          }
        }
      });

    case 'SECTION::ADD':
      return update(state, {
        sectionsContent: { $push: [action.newSection] }
      });

    case 'SECTION::MOVE':
      return update(state, {
        sectionsContent: {
          $arrayMove: {
            oldIndex: action.oldIndex,
            newIndex: action.newIndex
          }
        }
      });

    case 'SECTION::REMOVE':
      return update(state, {
        sectionsContent: {
          $splice: [[findSectionIndex(state, action), 1]]
        }
      });

    // BLOCKS

    case 'SECTION::BLOCK::ADD':
      return update(state, {
        sectionsContent: {
          [findSectionIndex(state, action)]: {
            blocks: { $push: [action.newBlock] }
          }
        }
      });

    case 'SECTION::BLOCK::MOVE':
      return update(state, {
        sectionsContent: {
          [findSectionIndex(state, action)]: {
            blocks: {
              $arrayMove: {
                oldIndex: action.oldIndex,
                newIndex: action.newIndex
              }
            }
          }
        }
      });

    case 'SECTION::BLOCK::REMOVE':
      sectionIndex = findSectionIndex(state, action);
      return update(state, {
        sectionsContent: {
          [sectionIndex]: {
            blocks: { $splice: [[findBlockIndex(sectionIndex, state, action), 1]] }
          }
        }
      });

    case 'SECTION::BLOCK::UPDATE_INPUT':
      sectionIndex = findSectionIndex(state, action);
      return update(state, {
        sectionsContent: {
          [sectionIndex]: {
            blocks: {
              [findBlockIndex(sectionIndex, state, action)]: {
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

export default page;
