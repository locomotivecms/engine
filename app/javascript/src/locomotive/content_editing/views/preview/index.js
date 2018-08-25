import React, { Component } from 'react';
import { find } from 'lodash';
import { waitUntil, getMetaContentFromIframe } from '../../utils/misc';
// import { fetchSectionContent } from '../../services/sections_service';

// HOC
import withRedux from '../../hoc/with_redux';

// Services
import {
  prepareIframe,
//   updateSection, updateSectionText,
//   previewSection, addSection, moveSection, removeSection,
//   selectSection, deselectSection, selectSectionBlock, deselectSectionBlock
} from '../../services/preview_service';

class Preview extends React.Component {

  constructor(props) {
    super(props);
    this.createdAt = new Date().getMilliseconds();
  }

  componentDidMount() {
    this.iframe.onload = () => {
      // bring some modifications to the iframe
      prepareIframe(this.iframe.contentWindow);

      // don't allow to go to another page if the changes have not been saved
      this.iframe.contentWindow.onbeforeunload = () => {
        return this.props.changed ? 'Changes unsaved!' : null;
      }

      if (!this.props.iframeState.loaded) {
        // alright, we are all good to display the first screen
        waitUntil(this.createdAt, null, () => this.props.onIframeLoaded(this.iframe.contentWindow))
      } else {
        // the user clicks on a link in the iframe.
        this.props.reloadEditor(
          this.props.api,
          getMetaContentFromIframe(this.iframe, 'locomotive-page-id'),
          getMetaContentFromIframe(this.iframe, 'locomotive-content-entry-id'),
          getMetaContentFromIframe(this.iframe, 'locomotive-locale')
        )
      }
    }
  }

  // componentDidUpdate(prevProps, prevState, snapshot) {
  //   this.refreshPreview(this.props.iframeState.refreshAction)
  //   .then(done => {
  //     if (done) this.props.onIframeOperationsDone();
  //   });
  // }

  // refreshPreview(action) {
  //   const _window = this.iframe.contentWindow;
  //   const { globalContent, api, iframeState } = this.props;
  //   const { section, blockId, previousSection } = iframeState;

  //   switch (action) {
  //     // case 'refreshSection':
  //     //   const sectionContent = fetchSectionContent(globalContent, section);
  //     //   return api.loadSectionHTML(section, sectionContent)
  //     //     .then(html => {
  //     //       updateSection(_window, section, html);
  //     //       selectSectionBlock(_window, section, blockId);
  //     //     });

  //     // case 'updateInput':
  //     //   const { fieldId, fieldValue } = iframeState;
  //     //   return updateSectionText(_window, section, blockId, fieldId, fieldValue);

  //     // case 'previewSection':
  //     //   return api.loadSectionHTML(section, section)
  //     //     .then(html => {
  //     //       previewSection(_window, html, section, previousSection);
  //     //       selectSection(_window, section);
  //     //     });

  //     // case 'moveSection':
  //     //   const { targetSection, direction } = this.props.iframeState;
  //     //   return moveSection(_window, section, targetSection, direction);

  //     // case 'removeSection':
  //     //   return removeSection(_window, section);

  //     // case 'selectSection':
  //     //   return selectSection(_window, section);

  //     // case 'deselectSection':
  //     //   return deselectSection(_window, section);

  //     // case 'selectSectionBlock':
  //     //   return selectSectionBlock(_window, section, blockId);

  //     // case 'deselectSectionBlock':
  //     //   return deselectSectionBlock(_window, section, blockId);

  //     default:
  //       return new Promise(resolve => { resolve() });
  //   }
  // }

  render() {
    return (
      <div className="content-preview preview">
        <div className="scrollable">
          <div className="embed-responsive embed-page">
            <iframe
              className="embed-responsive-item"
              src={this.props.src}
              ref={el => this.iframe = el}>
            </iframe>
          </div>
        </div>
      </div>
    )
  }

}

export default withRedux(state => ({
  // staticContent:      state.site.sectionsContent,
  // content:            state.page.sectionsContent,
  // dropzoneContent:    state.page.sectionsDropzoneContent,
  // site:               state.site,
  // page:               state.page,
  // globalContent:      state.content,
  iframeState:        state.iframe,
  // api:                state.editor.api,
  changed:            state.editor.changed
}))(Preview);
