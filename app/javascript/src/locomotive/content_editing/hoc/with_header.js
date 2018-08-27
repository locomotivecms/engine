import React from 'react';

// Components
import Header from '../components/header';

export default Component => {

  return function WrappedComponent(props) {
    return (
      <div className="editor-view">
        <Header {...props} />
        <Component {...props} />
      </div>
    )
  }

};
