function iframe(state = {}, action) {
  console.log(action.type, state);

  switch(action.type) {
    case 'IFRAME::LOADED':
      return { loaded: true, window: action.window };

    case 'EDIT_SECTION_INPUT':
      console.log(action);
      break;
  }
  return state;
}

export default iframe;
