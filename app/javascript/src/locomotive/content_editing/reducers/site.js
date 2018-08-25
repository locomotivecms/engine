import update from '../utils/immutable_update';
import { findIndex } from 'lodash';

function findBlockIndex(state, action) {
  const blocks = state.sectionsContent[action.sectionType].blocks;
  return findIndex(blocks, block => block.id === action.blockId);
}

function site(state = {}, action) {
  // switch(action.type) {

  //   case 'CONTENT::LOAD':
  //     return action.site;

  //   case 'SITE::SECTION::UPDATE_INPUT':
  //     return update(state, {
  //       sectionsContent: {
  //         [action.section.key]: {
  //           settings: {
  //             [action.id]: { $set: action.newValue }
  //           }
  //         }
  //       }
  //     });

  //   case 'SITE::SECTION::BLOCK::ADD':
  //     return update(state, {
  //       sectionsContent: {
  //         [action.section.key]: {
  //           blocks: { $push: [action.newBlock] }
  //         }
  //       }
  //     });

  //   case 'SITE::SECTION::BLOCK::MOVE':
  //     return update(state, {
  //       sectionsContent: {
  //         [action.section.key]: {
  //           blocks: {
  //             $arrayMove: {
  //               oldIndex: action.oldIndex,
  //               newIndex: action.newIndex
  //             }
  //           }
  //         }
  //       }
  //     });

  //   case 'SITE::SECTION::BLOCK::REMOVE':
  //     return update(state, {
  //       sectionsContent: {
  //         [action.sectionType]: {
  //           blocks: { $splice: [[findBlockIndex(state, action), 1]] }
  //         }
  //       }
  //     });

  //   // TODO
  //   case 'STATIC_SECTION::BLOCK::UPDATE_INPUT':
  //     return update(state, {
  //       sectionsContent: {
  //         [action.sectionType]: {
  //           blocks: {
  //             [findBlockIndex(state, action)]: {
  //               settings: {
  //                 [action.id]: { $set: action.newValue }
  //               }
  //             }
  //           }
  //         }
  //       }
  //     });

  //   default:
  //     return state;
  // }

  return state;
}

export default site;
