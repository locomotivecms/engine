import React, { Component } from 'react';
import ReactCrop from 'react-image-crop';
import { bindAll } from 'lodash';
import i18n from '../../i18n';

class Cropper extends Component {

  constructor(props) {
    super(props);

    this.state = {
      crop:             null,
      zoom:             1,
      applyCrop:        false,
      croppedImageUrl:  null
    };

    bindAll(this, 'apply', 'handleChange', 'handleImageLoaded', 'handleCroppedImageLoaded');
  }

  handleChange(crop) {
    this.setState({ crop, zoom: crop.width / this.state.minWidth });
  }

  handleImageLoaded(_image, pixelCrop) {
    const { image, cropSize } = this.props;
    const defaultCrop = this.getDefaultCrop(image, cropSize);
    var crop = defaultCrop;

    // Previous crop settings, if so, use them
    if (image.crop && image.crop.aspect === defaultCrop.aspect)
      crop = image.crop;

    // console.log('handleImageLoaded', image.width, image.height, '-', crop);

    this.setState({ crop, minWidth: defaultCrop.width });
  }

  handleCroppedImageLoaded() {
    const { crop, croppedImageUrl } = this.state;
    const { handleChange, image } = this.props;
    this.setState({ croppedImageUrl: null, applyCrop: false }, () => {
      handleChange({ ...image, cropped: croppedImageUrl, crop });
    });
  }

  apply() {
    const { crop, zoom } = this.state;
    const { image, cropSize, getThumbnail } = this.props;

    const r = Math.round;

    // Calculate the dimensions of the work zone
    const resizeWidth   = image.width / zoom;
    const resizeHeight  = image.height / zoom;

    // Calculate the dimensions of crop zone (not related to the zone selected by the editor)
    const cropWidth     = image.width < cropSize.width ? image.width : cropSize.width;
    const cropHeight    = image.height < cropSize.height ? image.height : cropSize.height;

    // Calculate the offset of the crop zone
    const cropX         = resizeWidth * crop.x / 100;
    const cropY         = resizeHeight * crop. y / 100;

    // Build the instructions for ImageMagick
    const format = `${r(resizeWidth)}x${r(resizeHeight)}|${r(cropWidth)}x${r(cropHeight)}+${r(cropX)}+${r(cropY)}`;

    // console.log('apply', format);

    // Ask the server to the Dragonfly url
    getThumbnail(image.source, format).then(croppedImageUrl => {
      this.setState({ croppedImageUrl, applyCrop: true });
    });
  }

  getDefaultCrop(image, cropSize) {
    const aspect  = cropSize.width / cropSize.height;
    const width   = cropSize.width / image.width * 100;

    // The main assumption is that either the width or the height is greater
    // than the related crop dimension.
    if (cropSize.width > image.width)
      return { x: 0, y: 0, width: 100, aspect: image.width / cropSize.height };

    if (cropSize.height > image.height)
      return { x: 0, y: 0, height: 100, aspect: cropSize.width / image.height };

    return { x: 0, y: 0, width: width, height: width / aspect, aspect };
  }

  render() {
    const { cropSize, image } = this.props;

    return (
      <div className="editor-image-cropper">
        <div className="editor-image-cropper-tool">
          <ReactCrop
            src={this.props.image.source}
            crop={this.state.crop}
            minWidth={this.state.minWidth}
            disabled={this.state.applyCrop}
            onChange={this.handleChange}
            onImageLoaded={this.handleImageLoaded}
          />
        </div>
        <div className="editor-image-cropper-action">
          <button className="btn btn-primary btn-sm" onClick={this.apply} disabled={this.state.applyCrop}>
            {this.state.applyCrop && <i className="fas fa-circle-notch fa-spin"></i>}
            {i18n.t(this.state.applyCrop ? 'components.cropper.action_in_progress' : 'components.cropper.action')}
          </button>
        </div>
        <img className="editor-image-cropper-preview" src={this.state.croppedImageUrl} onLoad={this.handleCroppedImageLoaded} />
      </div>
    )
  }
}

export default Cropper;
