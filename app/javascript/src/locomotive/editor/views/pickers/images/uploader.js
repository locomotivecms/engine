import React, { Component } from 'react';
import { bindAll, map, compact } from 'lodash';
import i18n from '../../../i18n';
import Compress from 'client-compress';

class Uploader extends Component {

  constructor(props) {
    super(props);
    this.state = { uploading: false };
    bindAll(this, 'openDialog', 'handleUpload');
  }

  openDialog() {
    this.input.click();
  }

  _handleUpload(files) {
    console.log(files)
    this.props.uploadAssets(files)
    .then((assets) => {
      this.setState({ uploading: false }, () => {
        this.props.handleUpload(assets[0]);
      });
    })
    .catch(error => { alert('error!', error) })
  }

  handleUpload(event) {
    const files = compact(map(event.target.files, file => file.size > window.Locomotive.maximum_uploaded_file_size ? null : file));

    if (files.length != event.target.files.length)
      alert(i18n.t('views.pickers.images.too_big'));

    if (files.length > 0)
      this.setState({ uploading: true }, () => {
        // do we have to compress the images on the browser before sending them to server?
        // https://www.npmjs.com/package/client-compress
        if (this.props.compress !== undefined) {
          const compress = new Compress(this.props.compress);
          compress.compress(files)
          .then(conversions => map(conversions, conversion => ({ blob: conversion.photo.data, filename: conversion.photo.name })))
          .then(_files => this._handleUpload(_files))
        } else
          this._handleUpload(files)
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
