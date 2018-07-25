import update from '../utils/immutable_update';

function editor(state = {}, action) {
  switch(action.type) {
    case 'EDITOR::LOAD':
      return action.editor;

    case 'PERSIST_CHANGES':
      return update(state, { changed: { $set: false } });

    case 'STATIC_SECTION::UPDATE_INPUT':
    case 'STATIC_SECTION::BLOCK::ADD':
    case 'STATIC_SECTION::BLOCK::MOVE':
    case 'STATIC_SECTION::BLOCK::REMOVE':
    case 'STATIC_SECTION::BLOCK::UPDATE_INPUT':
    case 'SECTION::UPDATE_INPUT':
    case 'SECTION::ADD':
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
