import React, { Component } from 'react';
import { bindAll } from 'lodash';
import i18n from '../../../i18n';

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
        <input type="file" ref={el => this.input = el} onChange={this.handleUpload} />
        {!this.state.uploading && (
          <a className="editor-image-uploader--button" onClick={this.openDialog}>
            {i18n.t('views.assets.images.add')}
          </a>
        )}

        {this.state.uploading && (
          <div className="editor-image-uploader--uploading">
            {i18n.t('views.assets.images.upload_in_progress')}
          </div>
        )}
      </div>
    )
  }

}

export default Uploader
