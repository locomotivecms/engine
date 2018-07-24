import React, { Component } from 'react';
import { compose } from 'redux';
import { BrowserRouter as Router, Switch, Route, Redirect, browserHistory } from 'react-router-dom';
import routes from '../routes';

// HOC
import withRedux from '../hoc/with_redux';
import withHeader from '../hoc/with_header';
import { withRouter } from 'react-router';

// Views
import _Startup from './startup.jsx';

console.log(browserHistory);

const Startup = withHeader(_Startup);

const togglePreview = (event) => {
  $('.content-main').toggleClass('actionbar-closed');
}

class Main extends Component {

  // constructor(props) {
  //   super(props);
  //   this.state = { reset: false };
  // }

  // componentDidUpdate(prevProps, prevState, snapshot) {
  //   // if (prevProps.iframe.loaded === true && !this.props.iframe.loaded) {
  //   //   // TODO
  //   //   console.log('redirect to the original url', prevProps.urls.base);
  //   //   console.log(this.switch);
  //   //   // browserHistory.replace(prevProps.urls.base);
  //   // }
  //   if (prevProps.iframe.loaded === true && !this.props.iframe.loaded) {
  //     console.log('editing a new page!');
  //     this.setState({ reset: true });
  //   }
  // }

  render() {
    console.log('Main', this.props.pageId);
    const pageId = this.props.pageId;

    return (
      <div className="actionbar">
        <div className="actionbar-trigger" onClick={togglePreview}>
          <i className="fa fa-chevron-left"></i>
        </div>
        <div className="content">
            <div className="container-fluid main" role="main">
              {!this.props.iframe.loaded && <Startup />}

              {this.props.iframe.loaded && (
               <Switch>
                  <Route exact path={`/${pageId}/content/edit/`} render={() => (
                    <Redirect to={`/${pageId}/content/edit/sections`} />
                  )} />

                  {routes.map(route => (
                    <Route
                      key={route.path}
                      exact={route.exact === true}
                      path={route.path}
                      render={(_props) => {
                        const Component = route.component;
                        return <Component {...this.props} {..._props} />
                      }}
                    />
                  ))}

                  <Route render={() => <Redirect to={`/${pageId}/content/edit/sections`} />} />
                </Switch>
              )}
            </div>
        </div>
      </div>
    )
  }

}

// const Main = props => (
//   <div className="actionbar">
//     <div className="actionbar-trigger" onClick={togglePreview}>
//       <i className="fa fa-chevron-left"></i>
//     </div>
//     <div className="content">
//       <Router history={browserHistory} basename={props.urls.base}>
//         <div className="container-fluid main" role="main">
//           {!props.iframe.loaded && <Startup />}

//           {props.iframe.loaded && (
//            <Switch>
//               <Route exact path="/" render={() => (
//                 <Redirect to="/sections" />
//               )} />

//               {routes.map(route => (
//                 <Route
//                   key={route.path}
//                   exact={route.exact === true}
//                   path={route.path}
//                   render={(_props) => {
//                     const Component = route.component;
//                     return <Component {...props} {..._props} />
//                   }}
//                 />
//               ))}

//               <Route render={() => <Redirect to="/" />} />
//             </Switch>
//           )}
//         </div>
//       </Router>
//     </div>
//   </div>
// )

// const _Main = withRedux(state => ({ iframe: state.iframe }))(Main)
// const __Main = props => <_Main {...props} />

// export default withRedux(state => ({
//   urls:   state.editor.urls,
//   api:    state.editor.api,
//   iframe: state.iframe
// }))(Main);

export default compose(
  withRouter,
  withRedux(state => ({
    pageId: state.page.id,
    api:    state.editor.api,
    iframe: state.iframe
  }))
)(Main);


// FIXME: building the API should happen once
// const _Main = withRedux(state => ({ iframe: state.iframe }))(Main)
// const __Main = props => <_Main {...props} />

// export default compose(
//   withRedux(state => ({ urls: state.editor.urls })),
//   withApi
// )(__Main);
