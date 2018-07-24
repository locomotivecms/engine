function editor(state = {}, action) {
  switch(action.type) {
    case 'EDITOR::LOAD':
      return action.editor ;

    default:
      return state;
  }
}

export default editor;
