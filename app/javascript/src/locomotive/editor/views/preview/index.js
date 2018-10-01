import React, { Component } from 'react';
import { waitUntil, getMetaContentFromIframe } from '../../utils/misc';
import { bindAll } from 'lodash';
import classnames from 'classnames';

// HOC
import withRedux from '../../hoc/with_redux';

// Components
import ActionBar from './action_bar';

// Services
import { prepareIframe } from '../../services/preview_service';

class Preview extends React.Component {

  constructor(props) {
    super(props);
    this.createdAt = new Date().getMilliseconds();
    bindAll(this, 'changeScreensize');
    this.state = { screensize: 'desktop' };
  }

  componentDidMount() {
    this.iframe.onload = () => {
      // bring some modifications to the iframe
      prepareIframe(this.iframe.contentWindow);

      // don't allow to go to another page if the changes have not been saved
      this.iframe.contentWindow.onbeforeunload = () => {
        return this.props.changed ? 'Changes unsaved!' : null;
      }

      this.iframe.contentWindow.onunload =() => {
        this.createdAt = new Date().getMilliseconds();
        this.props.startLoadingIframe(this.iframe.contentWindow);
      }

      if (this.props.iframeState.loaded === null) {
        // alright, we are all good to display the first screen
        waitUntil(this.createdAt, null, () => this.props.onIframeLoaded(this.iframe.contentWindow));
      } else {
        waitUntil(this.createdAt, null, () => {
          // the user clicks on a link in the iframe.
          this.props.reloadEditor(
            getMetaContentFromIframe(this.iframe, 'locomotive-page-id'),
            getMetaContentFromIframe(this.iframe, 'locomotive-content-entry-id'),
            getMetaContentFromIframe(this.iframe, 'locomotive-locale')
          )
        });
      }
    }
  }

  changeScreensize(screensize) {
    this.setState({ screensize });
  }

  // If no locale is included in the path (ex.: /index), Steam will use the
  // locale sent by the browser. We don't want this behavior when previewing the site
  // in the back-office, so we have to force the locale.
  getPreviewPath() {
    const { previewPath, currentLocale, defaultLocale } = this.props;
    return currentLocale === defaultLocale ? `${previewPath}?locale=${locale}` : previewPath;
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
            <div className="scrollable">
              <div className="embed-responsive embed-page">
                <iframe
                  className="embed-responsive-item"
                  src={this.getPreviewPath()}
                  ref={el => this.iframe = el}>
                </iframe>
              </div>
            </div>

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
