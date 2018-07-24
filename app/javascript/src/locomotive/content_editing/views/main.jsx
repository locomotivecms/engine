import React, { Component } from 'react';
import { compose } from 'redux';
import { Switch, Route, Redirect } from 'react-router-dom';
import routes from '../routes';

// HOC
import withRedux from '../hoc/with_redux';
import withHeader from '../hoc/with_header';
import { withRouter } from 'react-router';

// Views
import _Startup from './startup.jsx';

const Startup = withHeader(_Startup);

class Main extends Component {

  componentDidUpdate(prevProps) {
    if (prevProps.pageId !== this.props.pageId)
      this.props.history.replace(`/${this.props.pageId}/content/edit/sections`);
  }

  togglePreview(event) {
    $('.content-main').toggleClass('actionbar-closed');
  }

  render() {
    const { pageId, iframe } = this.props;
    return (
      <div className="actionbar">
        <div className="actionbar-trigger" onClick={this.togglePreview}>
          <i className="fa fa-chevron-left"></i>
        </div>
        <div className="content">
            <div className="container-fluid main" role="main">
              {!iframe.loaded && <Startup />}

              {iframe.loaded && (
               <Switch>
                  <Route exact path={`/${pageId}/content/edit/`} render={() => (
                    <Redirect to={`/${pageId}/content/edit/sections`} />
                  )} />

                  {routes.map(route => (
                    <Route
                      key={route.path}
                      exact={route.exact === true}
                      path={route.path}
                      component={route.component}
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

// const Main = ({ pageId, iframe, ...props }) => (
//   <div className="actionbar">
//     <div className="actionbar-trigger" onClick={togglePreview}>
//       <i className="fa fa-chevron-left"></i>
//     </div>
//     <div className="content">
//         <div className="container-fluid main" role="main">
//           {!iframe.loaded && <Startup />}

//           {iframe.loaded && (
//            <Switch>
//               <Route exact path={`/${pageId}/content/edit/`} render={() => (
//                 <Redirect to={`/${pageId}/content/edit/sections`} />
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

//               <Route render={() => <Redirect to={`/${pageId}/content/edit/sections`} />} />
//             </Switch>
//           )}
//         </div>
//     </div>
//   </div>
// )

export default compose(
  withRouter,
  withRedux(state => ({
    pageId: state.page.id,
    api:    state.editor.api,
    iframe: state.iframe
  }))
)(Main);
