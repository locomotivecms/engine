import React, { Component } from 'react';
import { compose } from 'redux';
import { find, last } from 'lodash';
import { waitUntil, getMetaContentFromIframe } from '../utils/misc';

// HOC
import { withRouter } from 'react-router';
import withRedux from '../hoc/with_redux';

// Services
import {
  updateSection, updateSectionText,
  previewSection, addSection, moveSection, removeSection,
  selectSection, deselectSection, selectSectionBlock, deselectSectionBlock
} from '../services/preview_service';

// we want to avoid the flickering if the iframe is loaded too quickly
const STARTUP_MIN_DELAY = 1000;

class Preview extends React.Component {

  constructor(props) {
    super(props);
    this.createdAt = new Date().getMilliseconds();
  }

  componentDidMount() {
    this.iframe.onload = () => {

      if (!this.props.iframeState.loaded) {
        waitUntil(
          this.createdAt,
          STARTUP_MIN_DELAY,
          () => { this.props.onIframeLoaded(this.iframe.contentWindow) }
        )
      } else {
        // x get the page id + locale from the iframe
        // x use a JSON builder to build the data + urls
        // x pass the urls to the API service!
        // x go grab the JSON used to build the editor
        // x refresh the UI
        // - change the URL (history.push)
        // - what if there are no sections (and editable elements)?
        // - changes not saved!
        // - waitUntil

        this.props.onIframeNewSrc();

        this.props.api.loadContent(
          getMetaContentFromIframe(this.iframe, 'locomotive-page-id'),
          getMetaContentFromIframe(this.iframe, 'locomotive-locale')
        ).then(response => {

          // this.props.history.push('/');
          this.props.loadEditor(response.json.data, response.json.urls);

          // console.log('TODO: change pageId');

          this.props.history.replace(`/${response.json.data.page.id}/content/edit/sections`);

          // console.log('HISTORY STATE', this.props.history.location.state);
          // window.history.replaceState(null, null, response.json.urls.base)
          // window.history.pushState(null, null, response.json.urls.base);
          // this.props.history.push('/');
        });
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

// export default withRedux(state => ({
//   staticContent:  state.site.sectionsContent,
//   content:        state.page.sectionsContent,
//   iframeState:    state.iframe,
//   api:            state.editor.api
// }))(Preview);

export default compose(
  withRouter,
  withRedux(state => ({
    staticContent:  state.site.sectionsContent,
    content:        state.page.sectionsContent,
    iframeState:    state.iframe,
    api:            state.editor.api
  }))
)(Preview);

