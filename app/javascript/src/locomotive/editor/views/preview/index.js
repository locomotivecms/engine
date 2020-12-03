import React, { Component } from 'react';
import { compose } from 'redux';
import { bindAll } from 'lodash';
import classnames from 'classnames';
import i18n from '../../i18n';

// HOC
import { withRouter } from 'react-router-dom';
import withRedux from '../../hoc/with_redux';
import withRoutes from '../../hoc/with_routes';

// Components
import ActionBar from './action_bar';
import Iframe from './iframe';

class Preview extends React.Component {

  constructor(props) {
    super(props);
    bindAll(this, 'changeScreensize');
    this.state = { screensize: 'desktop' };
  }

  changeScreensize(screensize) {
    this.setState({ screensize });
  }

  render() {
    const displayLoader = !this.props.iframeState.loaded || this.props.iframeState.failed;

    return (
      <div className="content-preview preview">
        <div className={classnames('preview-inner', this.state.screensize)}>
          <ActionBar
            changeScreensize={this.changeScreensize}
            currentScreensize={this.state.screensize}
            {...this.props}
          />

          <div className={classnames('preview-iframe', displayLoader ? 'preview-iframe--loading' : null)}>
            <Iframe {...this.props} />

            {displayLoader && (
              <div className="preview-iframe-loader">
                <img src={this.props.loaderImage} />
                {this.props.iframeState.failed && (<p>{i18n.t('views.preview.errorMessage')}</p>)}
              </div>
            )}
          </div>
        </div>
      </div>
    )
  }

}

export default compose(
  withRouter,
  withRedux(state => ({
    iframeState:        state.iframe,
    changed:            state.editor.changed,
    previewPath:        state.editor.urls.preview,
    loaderImage:        state.editor.urls.loaderImage,
    currentLocale:      state.editor.locale,
    defaultLocale:      state.editor.locales[0],
    routes:             state.editor.routes,
    sections:           state.editor.sections,
    globalContent:      state.content,
  })),
  withRoutes
)(Preview);
