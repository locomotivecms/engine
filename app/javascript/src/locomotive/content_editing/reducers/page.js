import update from '../utils/immutable_update';
import { findIndex } from 'lodash';

function findSectionIndex(state, action) {
  const sections = state.sectionsDropzoneContent;
  return findIndex(sections, section => section.id === action.sectionId);
}

function findBlockIndex(sectionIndex, state, action) {
  const blocks = state.sectionsDropzoneContent[sectionIndex].blocks;
  return findIndex(blocks, block => block.id === action.blockId);
}

function page(state = {}, action) {
  // var sectionIndex = null, blockIndex = null;

  // switch(action.type) {

  //   case 'EDITOR::LOAD':
  //     return action.page;

  //   // SECTIONS

  //   case 'PAGE::SECTION::UPDATE_INPUT':
  //     return update(state, {
  //       sectionsContent: {
  //         [action.section.key]: {
  //           settings: {
  //             [action.id]: { $set: action.newValue }
  //           }
  //         }
  //       }
  //     });

  //   case 'PAGE::SECTION::BLOCK::ADD':
  //     return update(state, {
  //       sectionsContent: {
  //         [action.section.key]: {
  //           blocks: { $push: [action.newBlock] }
  //         }
  //       }
  //     });

  //   case 'PAGE::SECTION::BLOCK::MOVE':
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


  //   // SECTIONS DROPZONE

  //   // TODO
  //   case 'SECTION::UPDATE_INPUT':
  //     return update(state, {
  //       sectionsDropzoneContent: {
  //         [findSectionIndex(state, action)]: {
  //           settings: {
  //             [action.id]: { $set: action.newValue }
  //           }
  //         }
  //       }
  //     });

  //   // TODO
  //   case 'SECTION::ADD':
  //     return update(state, {
  //       sectionsDropzoneContent: { $push: [action.newSection] }
  //     });

  //   // TODO
  //   case 'SECTION::MOVE':
  //     return update(state, {
  //       sectionsDropzoneContent: {
  //         $arrayMove: {
  //           oldIndex: action.oldIndex,
  //           newIndex: action.newIndex
  //         }
  //       }
  //     });

  //   // TODO
  //   case 'SECTION::REMOVE':
  //     return update(state, {
  //       sectionsDropzoneContent: {
  //         $splice: [[findSectionIndex(state, action), 1]]
  //       }
  //     });

  //   // BLOCKS

  //   // TODO
  //   case 'SECTION::BLOCK::ADD':
  //     return update(state, {
  //       sectionsDropzoneContent: {
  //         [findSectionIndex(state, action)]: {
  //           blocks: { $push: [action.newBlock] }
  //         }
  //       }
  //     });

  //   // TODO
  //   case 'SECTION::BLOCK::MOVE':
  //     return update(state, {
  //       sectionsDropzoneContent: {
  //         [findSectionIndex(state, action)]: {
  //           blocks: {
  //             $arrayMove: {
  //               oldIndex: action.oldIndex,
  //               newIndex: action.newIndex
  //             }
  //           }
  //         }
  //       }
  //     });

  //   // TODO
  //   case 'SECTION::BLOCK::REMOVE':
  //     sectionIndex = findSectionIndex(state, action);
  //     return update(state, {
  //       sectionsDropzoneContent: {
  //         [sectionIndex]: {
  //           blocks: { $splice: [[findBlockIndex(sectionIndex, state, action), 1]] }
  //         }
  //       }
  //     });

  //   // TODO
  //   case 'SECTION::BLOCK::UPDATE_INPUT':
  //     sectionIndex = findSectionIndex(state, action);
  //     return update(state, {
  //       sectionsDropzoneContent: {
  //         [sectionIndex]: {
  //           blocks: {
  //             [findBlockIndex(sectionIndex, state, action)]: {
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

export default page;
