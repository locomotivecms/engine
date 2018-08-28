import update from '../utils/immutable_update';

function iframe(state = {}, action) {
  switch (action.type) {

    case 'EDITOR::LOAD':
      return update(state, { loaded: { $set: true } });

    // IFRAME

    case 'IFRAME::NEW_SOURCE':
      return update(state, { loaded: { $set: false } });

    case 'IFRAME::LOADED':
      return { loaded: true, _window: action._window };

    case 'IFRAME::DONE':
      return update(state, {
        refreshAction:      { $set: null },
        refreshInput:       { $set: null },
        previousSection:    { $set: null }
      })

    // DROPZONE

    case 'DROPZONE::SECTION::PREVIEW':
      return update(state, { previousSection: { $set: action.newSection } });

    case 'DROPZONE::SECTION::CANCEL_PREVIEW':
      return update(state, { previousSection: { $set: null } });

    case 'DROPZONE::SECTION::ADD':
      return update(state, { previousSection: { $set: null } });

   default:
    return state;
  }
}

export default iframe;
