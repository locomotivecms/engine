import React, { Component } from 'react';
import withRedux from '../utils/with_redux';

class Preview extends React.Component {

  componentDidMount() {
    setTimeout(() => {
      this.props.onIframeLoaded(this.iframe.contentWindow);
    }, 1000);
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

export default withRedux(Preview, state => { return {} });
