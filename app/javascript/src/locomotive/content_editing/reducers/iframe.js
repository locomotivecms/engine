function iframe(state = {}, action) {
  switch(action.type) {
    case 'IFRAME::LOADED':
      return { loaded: true, window: action.window };
  }
  return state;
}

export default iframe;
