import update from '../utils/immutable_update';

function editor(state = {}, action) {
  switch(action.type) {

    case 'EDITOR::LOAD':
      return action.editor;

    case 'PERSIST_CHANGES':
      return action.success ? update(state, { changed: { $set: false } }) : state;

    case 'PAGE::PERSIST_CHANGES':
      return update(state, {
        pageChanged: { $set: !action.success },
        formErrors: { $set: action.success ? {} : action.errors }
      });

    case 'DROPZONE::SECTION::ADD':
      return update(state, {
        changed: { $set: true },
        sections: { all: { [action.newSection.uuid]: { $set: action.newSection } } }
      });

    case 'DROPZONE::SECTION::REMOVE':
      return update(state, {
        changed: { $set: true },
        sections: { all: { $unset: [action.section.uuid] } }
      });

    case 'PAGE::SETTING::UPDATE':
      return update(state, {
        changed: { $set: true },
        pageChanged: { $set: true }
      });

    case 'SITE::SECTION::UPDATE_INPUT':
    case 'SITE::SECTION::BLOCK::ADD':
    case 'SITE::SECTION::BLOCK::MOVE':
    case 'SITE::SECTION::BLOCK::REMOVE':
    case 'SITE::SECTION::BLOCK::UPDATE_INPUT':
    case 'PAGE::SECTION::UPDATE_INPUT':
    case 'PAGE::SECTION::BLOCK::ADD':
    case 'PAGE::SECTION::BLOCK::MOVE':
    case 'PAGE::SECTION::BLOCK::REMOVE':
    case 'PAGE::SECTION::BLOCK::UPDATE_INPUT':
    case 'DROPZONE::SECTION::UPDATE_INPUT':
    case 'DROPZONE::SECTION::MOVE':
    case 'DROPZONE::SECTION::BLOCK::ADD':
    case 'DROPZONE::SECTION::BLOCK::MOVE':
    case 'DROPZONE::SECTION::BLOCK::REMOVE':
    case 'DROPZONE::SECTION::BLOCK::UPDATE_INPUT':
      return update(state, { changed: { $set: true } });

    default:
      return state;
  }
}

export default editor;
