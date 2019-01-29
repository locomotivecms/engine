import React, { Component } from 'react';
import { bindAll, map, compact } from 'lodash';
import i18n from '../../../i18n';

const MAX_FILE_SIZE = 2048000;

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
    const files = compact(map(event.target.files, file => file.size > MAX_FILE_SIZE ? null : file));

    if (files.length != event.target.files.length)
      alert(i18n.t('views.pickers.images.too_big'));

    if (files.length > 0)
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
            {i18n.t('views.pickers.images.add')}
          </a>
        )}

        {this.state.uploading && (
          <div className="editor-image-uploader--uploading">
            {i18n.t('views.pickers.images.upload_in_progress')}
          </div>
        )}
      </div>
    )
  }

}

export default Uploader
