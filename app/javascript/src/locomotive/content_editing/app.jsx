import React, { Component } from 'react';

import { BrowserRouter as Router, Route, Link, browserHistory } from 'react-router-dom';
import { Provider } from 'react-redux';
import store from './store.js';

// Views
import ListSections from './sections/list.jsx';
import EditSection from './sections/edit.jsx';

// Components
import Header from './header.jsx';

const Foo = (props) => (<p>Foo</p>)

class App extends Component {

  render() {
    return (
      <Provider store={store}>
        <Router history={browserHistory} basename="/locomotive/foo/pages/5afc4c31e051bb2413aa58e6/content/edit">
          <div className="container-fluid main" role="main">
            <Header />
            <Route exact path="/" component={ListSections} />
            <Route path="/sections/:type/edit" component={EditSection}/>
            <Route exact path="/foo-bar" component={Foo} />
          </div>
        </Router>
      </Provider>
    )
  }

}

export default App;
