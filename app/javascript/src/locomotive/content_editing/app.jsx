import React, { Component } from 'react';
import { Provider } from 'react-redux';
import store from './store';
import { UrlsContext } from './context';

// Views/Components
import Main from './views/main.jsx';
import Preview from './components/preview.jsx';

class App extends Component {

  render() {
    return (
      <UrlsContext.Provider value={this.props.urls}>
        <Provider store={store}>
          <div>
            <Main basepath={this.props.urls.base} {...this.props} />
            <Preview src={this.props.urls.preview} />
          </div>
        </Provider>
      </UrlsContext.Provider>
    )
  }

}

export default App;
