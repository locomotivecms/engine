import React, { Component } from 'react';
import { find, last } from 'lodash';
import withRedux from '../utils/with_redux';
import { waitUntil } from '../utils/misc';

// Services
import {
  updateSection, updateSectionText,
  previewSection, addSection, moveSection, removeSection
} from '../services/preview_service';
import { loadSectionHTML } from '../services/api';

// we want to avoid the flickering if the iframe is loaded too quickly
const STARTUP_MIN_DELAY = 1000;

class Preview extends React.Component {

  constructor(props) {
    super(props);
    this.createdAt = new Date().getMilliseconds();
  }

  componentDidMount() {
    this.iframe.onload = () => {
      waitUntil(
        this.createdAt,
        STARTUP_MIN_DELAY,
        () => { this.props.onIframeLoaded(this.iframe.contentWindow) }
      )
    }
  }

  componentDidUpdate(prevProps, prevState, snapshot) {
    this.refreshPreview(this.props.iframeState.refreshAction)
    .then(done => {
      if (done) this.props.onIframeOperationsDone
    });
  }

  refreshPreview(action) {
    const _window = this.iframe.contentWindow;
    const { sectionType, sectionId } = this.props.iframeState;

    switch(action) {
      case 'refreshStaticSection':
        return loadSectionHTML(sectionType, this.props.staticContent[sectionType])
          .then(html => updateSection(_window, sectionType, html))

      case 'updateInput':
        const { blockId, fieldId, fieldValue } = this.props.iframeState;
        return updateSectionText(_window, sectionType, sectionId, blockId, fieldId, fieldValue);

      case 'previewSection':
        const { section, previousSectionId } = this.props.iframeState;
        return loadSectionHTML(section.type, section)
          .then(html => previewSection(_window, html, previousSectionId))

      case 'refreshSection':
        const _section = find(this.props.content, _section => _section.id === sectionId);
        return loadSectionHTML(sectionType, _section)
          .then(html => updateSection(_window, sectionId, html))

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

export default withRedux(Preview, state => { return {
  staticContent:  state.site.sectionsContent,
  content:        state.page.sectionsContent,
  iframeState:    state.iframe
} });
