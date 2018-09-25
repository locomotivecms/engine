import React, { Component } from 'react';
import { Provider } from 'react-redux';
import { BrowserRouter as Router, browserHistory } from 'react-router-dom';

import store from './store';

// Views/Components
import Shield from './components/shield';
import ActionBar from './views/action_bar';
import Preview from './views/preview';

const App = props => (
  <Provider store={store}>
    <Router history={browserHistory} basename={props.basePath}>
      <Shield image={store.getState().editor.urls.deadendImage}>
        <div>
          <ActionBar />
          <Preview src={props.previewPath} />
        </div>
      </Shield>
    </Router>
  </Provider>
)

export default App;
