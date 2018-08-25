import update from '../utils/immutable_update';

// const refreshSection = (state, action) => {
//   return update(state, {
//     refreshAction:  { $set: 'refreshSection' },
//     section:        { $set: action.section },
//     blockType:      { $set: action.blockType },
//     blockId:        { $set: action.blockId }
//   });
// }

function iframe(state = {}, action) {
  switch (action.type) {

    case 'EDITOR::LOAD':
      return { loaded: true };

    case 'IFRAME::NEW_SOURCE':
      return { loaded: false };

    case 'IFRAME::LOADED':
      return { loaded: true, window: action.window, _window: action.window };

    case 'IFRAME::DONE':
      return update(state, {
        refreshAction:      { $set: null },
        refreshInput:       { $set: null },
        previousSection:    { $set: null }
      })

    // // SECTION INPUTS
    // case 'SITE::SECTION::UPDATE_INPUT':
    // case 'PAGE::SECTION::UPDATE_INPUT':
    // case 'DROPZONE::SECTION::UPDATE_INPUT':
    // case 'SITE::SECTION::BLOCK::UPDATE_INPUT':
    // case 'PAGE::SECTION::BLOCK::UPDATE_INPUT':
    // case 'DROPZONE::SECTION::BLOCK::UPDATE_INPUT':
    //   if (action.fieldType === 'text')
    //     return update(state, {
    //       refreshAction:    { $set: 'updateInput' },
    //       section:          { $set: action.section },
    //       blockId:          { $set: action.blockId },
    //       fieldId:          { $set: action.id },
    //       fieldValue:       { $set: action.newValue }
    //     });
    //   else
    //     return refreshSection(state, action);

    // SECTION BLOCKS
    // case 'SITE::SECTION::BLOCK::ADD':
    // case 'SITE::SECTION::BLOCK::REMOVE':
    // case 'SITE::SECTION::BLOCK::MOVE':
    // case 'PAGE::SECTION::BLOCK::ADD':
    // case 'PAGE::SECTION::BLOCK::REMOVE':
    // case 'PAGE::SECTION::BLOCK::MOVE':
    // case 'DROPZONE::SECTION::BLOCK::ADD':
    // case 'DROPZONE::SECTION::BLOCK::REMOVE':
    // case 'DROPZONE::SECTION::BLOCK::MOVE':
    //   return refreshSection(state, action);

    // DROPZONE
    case 'DROPZONE::SECTION::PREVIEW':
      return update(state, { previousSection: { $set: action.newSection } });

    case 'DROPZONE::SECTION::CANCEL_PREVIEW':
      return update(state, { previousSection: { $set: null } });

    case 'DROPZONE::SECTION::ADD':
      return update(state, { previousSection: { $set: null } });

    // case 'DROPZONE::SECTION::REMOVE':
    //   return update(state, {
    //     refreshAction:      { $set: 'removeSection' },
    //     section:            { $set: action.section }
    //   });

    // case 'DROPZONE::SECTION::MOVE':
    //   return update(state, {
    //     refreshAction:      { $set: 'moveSection' },
    //     section:            { $set: action.section },
    //     targetSection:      { $set: action.targetSection },
    //     direction:          { $set: action.newIndex > action.oldIndex ? 'after' : 'before' }
    //   });

    // SELECT/UNSELECT SECTIONS/BLOCKs

    // case 'SECTION::SELECT':
    //   return update(state, {
    //     refreshAction:      { $set: 'selectSection' },
    //     section:            { $set: action.section }
    //   });

    // case 'SECTION::DESELECT':
    //   return update(state, {
    //     refreshAction:      { $set: 'deselectSection' },
    //     section:            { $set: action.section }
    //   });

    // case 'SECTION::BLOCK::SELECT':
    //   return update(state, {
    //     refreshAction:      { $set: 'selectSectionBlock' },
    //     section:            { $set: action.section },
    //     blockId:            { $set: action.blockId }
    //   });

    // case 'SECTION::BLOCK::DESELECT':
    //   return update(state, {
    //     refreshAction:      { $set: 'deselectSectionBlock' },
    //     section:            { $set: action.section },
    //     blockId:            { $set: action.blockId }
    //   });

   default:
    return state;
  }
}

export default iframe;
