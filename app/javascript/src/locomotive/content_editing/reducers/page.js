function page(state = [], action) {
  switch(action.type) {
    case 'PERSIST_CHANGES':
      // console.log('PAGE', 'PERSIST_CHANGES', state);
      return state;
  }

  return state;
}

export default page;
