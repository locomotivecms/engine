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

// Views
import Startup from '../startup';
import Main from './main';

class ActionBar extends Component {

  componentDidUpdate(prevProps) {
    if (prevProps.pageId !== this.props.pageId) {
      const pageId = compact([this.props.pageId, this.props.contentEntryId]).join('-');
      this.props.history.replace(`/${pageId}/content/edit`);
    }
  }

  render() {
    const { pageId, iframeLoaded, location } = this.props;
    const currentKey      = iframeLoaded ? location.pathname : 'startup';
    const slideDirection  = !iframeLoaded ? 'up' : (location.state || {}).slideDirection || 'up';

    return (
      <div className="actionbar">
        <Header />

        <TransitionGroup className="editor-route-wrapper">
          <CSSTransition
            key={currentKey}
            classNames={`slide-${slideDirection}`}
            timeout={{ enter: 150, exit: 100 }}
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

              <Route render={() => <Redirect to={`/${pageId}/content/edit`} />} />

            </Switch>
          </CSSTransition>
        </TransitionGroup>
      </div>
    )
  }
}

export { ActionBar };

export default compose(
  withRouter,
  withRedux(state => ({
    pageId:         state.content.page.id,
    contentEntryId: state.content.page.contentEntryId,
    iframeLoaded:   state.iframe.loaded
  }))
)(ActionBar);
