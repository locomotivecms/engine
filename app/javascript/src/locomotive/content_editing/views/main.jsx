import React from 'react';
import routes from '../routes';
import { BrowserRouter as Router, Switch, Route, Redirect, browserHistory } from 'react-router-dom';

// HOC
import withRedux from '../hoc/with_redux';
import withHeader from '../hoc/with_header';

// Views
import _Startup from './startup.jsx';

const Startup = withHeader(_Startup);

const togglePreview = (event) => {
  $('.content-main').toggleClass('actionbar-closed');
}

const Main = props => (
  <div className="actionbar">
    <div className="actionbar-trigger" onClick={togglePreview}>
      <i className="fa fa-chevron-left"></i>
    </div>
    <div className="content">
      <Router history={browserHistory} basename={props.basepath}>
        <div className="container-fluid main" role="main">
          {!props.iframe.loaded && <Startup />}

          {props.iframe.loaded && (
           <Switch>
              <Route exact path="/" render={() => (
                <Redirect to="/sections" />
              )} />

              {routes.map(route => (
                <Route
                  key={route.path}
                  exact={route.exact === true}
                  path={route.path}
                  component={route.component}
                />
              ))}

              <Route render={() => <Redirect to="/" />} />
            </Switch>
          )}
        </div>
      </Router>
    </div>
  </div>
)

export default withRedux(state => ({ iframe: state.iframe }))(Main);
