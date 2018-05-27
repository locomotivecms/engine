import React, { Component } from 'react';
import withRedux from '../utils/with_redux';
import { waitUntil } from '../utils/misc';

// Services
import { updateStaticSection as previewUpdateStaticSection } from '../services/preview_service';
import { loadSectionHTML } from '../services/api.js';

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
    const { iframe, site, page } = this.props;

    if (iframe.refreshStaticSection) {
      loadSectionHTML(iframe.sectionType, site.sectionsContent)
      .then(html => {
        previewUpdateStaticSection(
          iframe.window,
          iframe.sectionType,
          html
        );

        // TODO: dispatch action to tell the action is done
      });
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
  site:     state.site,
  iframe:   state.iframe
} });
