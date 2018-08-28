import React, { Component } from 'react';
import { compose } from 'redux';
import { Switch, Route, Redirect } from 'react-router-dom';
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

  togglePreview(event) {
    $('.content-main').toggleClass('actionbar-closed');
  }

  render() {
    const { pageId, iframe } = this.props;

    return (
      <div className="actionbar">
        <Header />

        <Menu />

        <div className="actionbar-content">
          <div className="scrollable">
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

export { Main };

export default compose(
  withRouter,
  withRedux(state => ({
    pageId:         state.content.page.id,
    contentEntryId: state.content.page.contentEntryId,
    iframe:         state.iframe
  }))
)(Main);
