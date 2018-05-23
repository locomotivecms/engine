import update from 'immutability-helper';

function site(state = {}, action) {

  switch(action.type) {
    case 'SECTION::UPDATE_INPUT':
      if (!action.static) return state;
      return update(state, {
        sectionsContent: {
          [action.sectionType]: {
            settings: {
              [action.id]: { $set: action.newValue }
            }
          }
        }
      });

    default:
      return state;
  }
}

export default site;
