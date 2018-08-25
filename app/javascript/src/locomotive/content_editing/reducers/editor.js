import update from '../utils/immutable_update';

// TODO: SITE::SECTION::UPDATE_INPUT
// TODO: PAGE::SECTION::UPDATE_INPUT

function editor(state = {}, action) {
  switch(action.type) {
    case 'EDITOR::LOAD':
      return action.editor;

    case 'PERSIST_CHANGES':
      return update(state, { changed: { $set: false } });

    case 'DROPZONE::SECTION::ADD':
      return update(state, {
        changed: { $set: true },
        sections: { all: { [action.newSection.uuid]: { $set: action.newSection } } }
      });

    case 'SITE::UPDATE_INPUT':
    case 'SITE::BLOCK::ADD':
    case 'SITE::BLOCK::MOVE':
    case 'SITE::BLOCK::REMOVE':
    case 'SITE::BLOCK::UPDATE_INPUT':
    case 'PAGE::UPDATE_INPUT':
    case 'PAGE::BLOCK::ADD':
    case 'PAGE::BLOCK::MOVE':
    case 'PAGE::BLOCK::REMOVE':
    case 'PAGE::BLOCK::UPDATE_INPUT':
    case 'SECTION::UPDATE_INPUT':
    case 'SECTION::MOVE':
    case 'SECTION::REMOVE':
    case 'SECTION::BLOCK::ADD':
    case 'SECTION::BLOCK::MOVE':
    case 'SECTION::BLOCK::REMOVE':
    case 'SECTION::BLOCK::UPDATE_INPUT':
      return update(state, { changed: { $set: true } });

    default:
      return state;
  }
}

export default editor;
