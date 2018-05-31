import update from '../utils/immutable_update';

const refreshStaticSection = (state, action) => {
  return update(state, {
    refreshAction:  { $set: 'staticSection' },
    sectionType:    { $set: action.sectionType }
  });
}

// const refreshSection = (state, action) => {
//   return update(state, {
//     refreshAction:  { $set: 'section' },
//     sectionId:      { $set: action.sectionId }
//   });
// }

function iframe(state = {}, action) {
  switch(action.type) {
    case 'IFRAME::LOADED':
      return { loaded: true, window: action.window };

    case 'SECTION::MOVE':
      return update(state, {
        refreshAction:    { $set: 'moveSection' },
        sectionId:        { $set: action.sectionId },
        targetSectionId:  { $set: action.targetSectionId },
        direction:        { $set: action.newIndex > action.oldIndex ? 'after' : 'before' }
      });

    case 'SECTION::UPDATE_INPUT':
    case 'SECTION::BLOCK::UPDATE_INPUT':
    case 'STATIC_SECTION::BLOCK::UPDATE_INPUT':
    case 'STATIC_SECTION::UPDATE_INPUT':
      if (action.fieldType === 'text')
        return update(state, {
          refreshAction:  { $set: 'input' },
          sectionType:    { $set: action.sectionType },
          sectionId:      { $set: action.sectionId },
          blockId:        { $set: action.blockId },
          fieldId:        { $set: action.id },
          fieldValue:     { $set: action.newValue }
        });
      else
        return refreshStaticSection(state, action);

    case 'STATIC_SECTION::BLOCK::ADD':
    case 'STATIC_SECTION::BLOCK::REMOVE':
    case 'STATIC_SECTION::BLOCK::MOVE':
      return refreshStaticSection(state, action);

    case 'IFRAME::DONE':
      return update(state, {
        refreshAction:  { $set: null },
        refreshInput:   { $set: null }
      })

   default:
    return state;
  }
}

export default iframe;
