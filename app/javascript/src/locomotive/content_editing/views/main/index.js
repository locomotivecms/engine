import React, { Component } from 'react';
import { compose } from 'redux';
import { Switch, Route, Redirect } from 'react-router-dom';
import { TransitionGroup, CSSTransition } from 'react-transition-group';
import { compact } from 'lodash';
import routes from '../../routes';

// HOC
import withRedux from '../../hoc/with_redux';
import { withRouter } from 'react-router';

// Components
import Header from './header';
import Menu from './menu';

// Views
import Startup from '../startup';

class Main extends Component {

  componentDidUpdate(prevProps) {
    if (prevProps.pageId !== this.props.pageId) {
      const pageId = compact([this.props.pageId, this.props.contentEntryId]).join('-');
      this.props.history.replace(`/${pageId}/content/edit/sections`);
    }
  }

  render() {
    const { pageId, iframeLoaded, location } = this.props;
    const currentKey      = iframeLoaded ? location.pathname : 'startup';
    const slideDirection  = !iframeLoaded ? 'up' : (location.state || {}).slideDirection || 'up';

    console.log(location.pathname);

    return (
      <div className="actionbar">
        <Header />
        <Menu {...this.props} />
        <TransitionGroup className="editor-route-wrapper">
          <CSSTransition
            key={currentKey}
            classNames={`slide-${slideDirection}`}
            timeout={{ enter: 300, exit: 200 }}
            mountOnEnter={true}
            unmountOnExit={true}
          >
            <Switch location={location}>
              {!iframeLoaded && <Route path={`/${pageId}/content/edit/`} component={Startup} />}

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
          </CSSTransition>
        </TransitionGroup>
      </div>
    )
  }
}

export { Main };

export default compose(
  withRouter,
  withRedux(state => ({
    pageId:         state.content.page.id,
    contentEntryId: state.content.page.contentEntryId,
    iframeLoaded:   state.iframe.loaded
  }))
)(Main);
