import React, { Component } from 'react';
import { waitUntil, getMetaContentFromIframe } from '../../utils/misc';
import classnames from 'classnames';
import { bindAll } from 'lodash';

// Services
import { prepareIframe, PREVIEW_LOADING_TIME_OUT } from '../../services/preview_service';
import { findFromTextId as findSectionFromTextId } from '../../services/sections_service';

class Iframe extends React.Component {

  constructor(props) {
    super(props);
    this.createdAt = new Date().getMilliseconds();
    bindAll(this, 'selectTextInput');
  }

  componentDidMount() {
    const { startLoadingIframe, stopLoadingIframe, onIframeLoaded, reloadEditor, selectIframeTextInput } = this.props;
    const loadingTimeout = setTimeout(() => stopLoadingIframe(), PREVIEW_LOADING_TIME_OUT);

    window.document.addEventListener('LocomotivePreviewReady', event => {
      // stop the loading timeout timer!
      clearTimeout(loadingTimeout);

      // bring some nice modifications to the iframe so that it becomes interactive
      prepareIframe(this.iframe.contentWindow, { selectTextInput: this.selectTextInput });

      // don't allow to go to another page if the changes have not been saved
      this.iframe.contentWindow.onbeforeunload = () => {
        return this.props.changed ? 'Changes unsaved!' : null;
      }

      this.iframe.contentWindow.onunload =() => {
        this.createdAt = new Date().getMilliseconds();
        if (this.iframe?.contentWindow)
          startLoadingIframe(this.iframe.contentWindow);
      }

      if (this.props.iframeState.loaded === null) {
        // alright, we are all good to display the first screen
        waitUntil(this.createdAt, null, () => onIframeLoaded(this.iframe.contentWindow));
      } else {
        waitUntil(this.createdAt, null, () => {
          // the user clicks on a link in the iframe.
          reloadEditor(
            getMetaContentFromIframe(this.iframe, 'locomotive-page-id'),
            getMetaContentFromIframe(this.iframe, 'locomotive-content-entry-id'),
            getMetaContentFromIframe(this.iframe, 'locomotive-locale')
          )
        });
      }
    });    
  }

  // Go to the view (section or block form) where is located the input setting
  selectTextInput(textId) {
    console.log('selectTextInput [NEW]', textId);

    const { sections, focusSectionSettingPath, redirectTo } = this.props;
    const { sectionId, blockId, settingId } = findSectionFromTextId(sections, textId);
    
    if (!sectionId && !blockId) {
      console.log('[Editor] unknown sectionId and blockId');
      return;
    }

    let path = focusSectionSettingPath({ uuid: sectionId }, 'text', settingId);

    console.log('[IFrame][selectTextInput]', path);

    // in this UX context, we don't need to apply the sliding animation
    redirectTo(path, 'none');
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