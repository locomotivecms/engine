import React, { Component } from 'react';
import { Provider } from 'react-redux';
import { pick } from 'lodash';
import store from './store';
import GlobalContext from './context';

// Views/Components
import Main from './views/main.jsx';
import Preview from './views/preview.jsx';

const App = props => (
  <GlobalContext.Provider value={pick(props,
    'urls', 'sections', 'sectionDefinitions', 'hasSections', 'hasEditableElements'
  )}>
    <Provider store={store}>
      <div>
        <Main basepath={props.urls.base} {...props} />
        <Preview src={props.urls.preview} />
      </div>
    </Provider>
  </GlobalContext.Provider>
)

export default App;
