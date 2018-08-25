import React, { Component } from 'react';
import { Provider } from 'react-redux';
import { BrowserRouter as Router, browserHistory } from 'react-router-dom';

import store from './store';

// Views/Components
import Main from './views/main';
import Preview from './views/preview';

const App = props => (
  <Provider store={store}>
    <Router history={browserHistory} basename={props.basePath}>
      <div>
        <Main />
        <Preview src={props.previewPath} />
      </div>
    </Router>
  </Provider>
)

export default App;
