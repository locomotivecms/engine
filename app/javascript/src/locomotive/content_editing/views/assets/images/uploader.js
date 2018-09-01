import React, { Component } from 'react';
import { bindAll } from 'lodash';

class Uploader extends Component {

  constructor(props) {
    super(props);
    this.state = { uploading: false };
    bindAll(this, 'openDialog', 'handleUpload');
  }

  openDialog() {
    this.input.click();
  }

  handleUpload(event) {
    const files = event.target.files;

    this.setState({ uploading: true }, () => {
      this.props.uploadAssets(files)
      .then((assets) => {
        this.setState({ uploading: false }, () => {
          this.props.handleUpload(assets[0]);
        });
      })
      .catch(error => { alert('error!', error) })
    });
  }

  render() {
    return (
      <div className="editor-image-uploader">
        {this.state.uploading ? (
          <div>
            <p>Uploading...</p>
          </div>
        ) : (
          <div>
            <input type="file" ref={el => this.input = el} onChange={this.handleUpload} />
            <button className="btn btn-primary btn-sm" onClick={this.openDialog}>
              Upload
            </button>
          </div>
        )}
      </div>
    )
  }

}

export default Uploader
