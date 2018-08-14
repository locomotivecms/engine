import React, { Component } from 'react';
import { find } from 'lodash';
import { waitUntil, getMetaContentFromIframe } from '../utils/misc';

// HOC
import withRedux from '../hoc/with_redux';

// Services
import {
  prepareIframe,
  updateSection, updateSectionText,
  previewSection, addSection, moveSection, removeSection,
  selectSection, deselectSection, selectSectionBlock, deselectSectionBlock
} from '../services/preview_service';

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

  componentDidUpdate(prevProps, prevState, snapshot) {
    this.refreshPreview(this.props.iframeState.refreshAction)
    .then(done => {
      if (done) this.props.onIframeOperationsDone();
    });
  }

  refreshPreview(action) {
    const _window = this.iframe.contentWindow;
    const { api, iframeState } = this.props;
    const { sectionType, sectionId, blockId } = iframeState;

    switch(action) {
      case 'refreshStaticSection':
        return api.loadSectionHTML(sectionType, this.props.staticContent[sectionType])
          .then(html => updateSection(_window, sectionType, html))

      case 'updateInput':
        const { fieldId, fieldValue } = this.props.iframeState;
        return updateSectionText(_window, sectionType, sectionId, blockId, fieldId, fieldValue);

      case 'previewSection':
        const { section, previousSectionId } = this.props.iframeState;
        return api.loadSectionHTML(section.type, section)
          .then(html => previewSection(_window, html, section.id, previousSectionId))

      case 'refreshSection':
        const _section = find(this.props.content, _section => _section.id === sectionId);
        return api.loadSectionHTML(sectionType, _section)
          .then(html => {
            updateSection(_window, sectionId, html)
            selectSectionBlock(_window, sectionId, blockId);
          })

      case 'selectSection':
        return selectSection(_window, sectionId);

      case 'deselectSection':
        return deselectSection(_window, sectionId);

      case 'selectSectionBlock':
        return selectSectionBlock(_window, sectionId, blockId);

      case 'deselectSectionBlock':
        return deselectSectionBlock(_window, sectionId, blockId);

      case 'moveSection':
        const { targetSectionId, direction } = this.props.iframeState;
        return moveSection(_window, sectionId, targetSectionId, direction);

      case 'removeSection':
        return removeSection(_window, sectionId);

      default:
        return new Promise(resolve => { resolve() });
    }
  }

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
  staticContent:  state.site.sectionsContent,
  content:        state.page.sectionsDropzoneContent,
  iframeState:    state.iframe,
  api:            state.editor.api,
  changed:        state.editor.changed
}))(Preview);
