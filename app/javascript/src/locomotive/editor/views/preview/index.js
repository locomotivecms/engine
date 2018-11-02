import React, { Component } from 'react';
import { bindAll } from 'lodash';
import classnames from 'classnames';

// HOC
import withRedux from '../../hoc/with_redux';

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
    return (
      <div className="content-preview preview">
        <div className={classnames('preview-inner', this.state.screensize)}>
          <ActionBar
            changeScreensize={this.changeScreensize}
            currentScreensize={this.state.screensize}
            {...this.props}
          />

          <div className={classnames('preview-iframe', this.props.iframeState.loaded !== true ? 'preview-iframe--loading' : null)}>
            <Iframe {...this.props} />

            {!this.props.iframeState.loaded && (
              <div className="preview-iframe-loader">
                <img src={this.props.loaderImage} />
              </div>
            )}
          </div>
        </div>
      </div>
    )
  }

}

export default withRedux(state => ({
  iframeState:        state.iframe,
  changed:            state.editor.changed,
  previewPath:        state.editor.urls.preview,
  loaderImage:        state.editor.urls.loaderImage,
  currentLocale:      state.editor.locale,
  defaultLocale:      state.editor.locales[0]
}))(Preview);
