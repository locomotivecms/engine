import update from '../utils/immutable_update';

function view(state = {}, action) {
  switch(action.type) {

    case 'SECTION::SELECT':
      return update(state, {
        staticSection:  { $set: action.sectionId !== null },
        sectionType:    { $set: action.sectionType },
        sectionId:      { $set: action.sectionId }
      });

    case 'SECTION::BLOCK::SELECT':
      return update(state, {
        staticSection:  { $set: action.sectionId !== null },
        sectionType:    { $set: action.sectionType },
        sectionId:      { $set: action.sectionId },
        blockType:      { $set: action.blockType },
        blockId:        { $set: action.blockId }
      });

    case 'SECTION::EDIT_SETTING':
      return update(state, {
        settingId:  { $set: action.settingId }
      });

    default:
      return state;
  }
}

export default view;
