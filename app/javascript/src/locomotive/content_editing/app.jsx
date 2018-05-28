import React, { Component } from 'react';
import { Provider } from 'react-redux';
import store from './store.js';

// Views/Components
import Main from './views/main.jsx';
import Preview from './components/preview.jsx';

class App extends Component {

  render() {
    return (
      <Provider store={store}>
        <div>
          <Main basepath={this.props.urls.base} {...this.props} />
          <Preview src={this.props.urls.preview} />
        </div>
      </Provider>
    )
  }

}

export default App;
