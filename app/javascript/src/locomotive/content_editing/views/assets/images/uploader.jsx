import React, { Component } from 'react';
import { uploadAssets } from '../../../services/api';

class Uploader extends Component {

  constructor(props) {
    super(props);

    this.state = { uploading: false };

    this.openDialog = this.openDialog.bind(this);
    this.upload     = this.upload.bind(this);
  }

  openDialog() {
    this.input.click();
  }

  upload(event) {
    const files = event.target.files;

    this.setState({ uploading: true }, () => {
      uploadAssets(files)
      .then((assets) => {
        this.setState({ uploading: false }, () => {
          this.props.onUpload(assets[0].id);
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
            <p>Uploading file....</p>
          </div>
        ) : (
          <div>
            <input type="file" ref={el => this.input = el} onChange={this.upload} />
            <button className="btn btn-primary btn-sm" onClick={this.openDialog}>
              Upload file
            </button>
          </div>
        )}
      </div>
    )
  }

}

export default Uploader
