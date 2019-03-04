import React, { Component } from 'react';
import { waitUntil, getMetaContentFromIframe } from '../../utils/misc';
import classnames from 'classnames';

// Services
import { prepareIframe } from '../../services/preview_service';

class Iframe extends React.Component {

  constructor(props) {
    super(props);
    this.createdAt = new Date().getMilliseconds();
  }

  componentDidMount() {
    window.document.addEventListener('LocomotivePreviewReady', event => {
      // bring some modifications to the iframe
      prepareIframe(this.iframe.contentWindow);

      // don't allow to go to another page if the changes have not been saved
      this.iframe.contentWindow.onbeforeunload = () => {
        return this.props.changed ? 'Changes unsaved!' : null;
      }

      this.iframe.contentWindow.onunload =() => {
        this.createdAt = new Date().getMilliseconds();

        if (this.iframe?.contentWindow)
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

    });
  }

  // If no locale is included in the path (ex.: /index), Steam will use the
  // locale sent by the browser. We don't want this behavior when previewing the site
  // in the back-office, so we have to force the locale.
  getPreviewPath() {
    const { previewPath, currentLocale, defaultLocale } = this.props;
    return currentLocale === defaultLocale ? `${previewPath}?locale=${currentLocale}` : previewPath;
  }

  shouldComponentUpdate() {
    // guarantees that the iframe will be not reloaded.
    return false;
  }

  render() {
    return (
      <div className="scrollable">
        <div className="embed-responsive embed-page">
          <iframe
            className="embed-responsive-item"
            src={this.getPreviewPath()}
            ref={el => this.iframe = el}>
          </iframe>
        </div>
      </div>
    )
  }

}

export default Iframe;
