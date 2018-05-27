import update from '../utils/immutable_update';

function iframe(state = {}, action) {
  switch(action.type) {
    case 'IFRAME::LOADED':
      return { loaded: true, window: action.window };

    case 'STATIC_SECTION::BLOCK::ADD':
    case 'STATIC_SECTION::BLOCK::REMOVE':
    case 'STATIC_SECTION::BLOCK::MOVE':
      return update(state, {
        refreshStaticSection: { $set: true },
        sectionType: { $set: action.sectionType }
      });

   default:
    return state;
  }
}

export default iframe;
