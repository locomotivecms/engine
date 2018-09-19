import React, { Component } from 'react';
import { compose } from 'redux';
import ReactCrop from 'react-image-crop';
import { bindAll } from 'lodash';

// HOC
import { withRouter } from 'react-router-dom';
import withRoutes from '../hoc/with_routes';
import withRedux from '../hoc/with_redux';

// Components
import Modal from '../components/modal';
import Cropper from '../components/cropper';

const openLibrary = props => {
  props.redirectTo(props.imagesPath(
    props.section,
    props.blockType,
    props.blockId,
    props.setting.type,
    props.setting.id
  ), 'left');
}

class ImagePickerInput extends Component {

  constructor(props) {
    super(props);
    this.state = { isModalOpened: false };
    bindAll(this, 'handleCropChange');
  }

  handleCropChange(value) {
    this.setState({ isModalOpened: false }, () => {
      this.props.handleChange(value);
    })
  }

  isCroppable(image, setting) {
    return setting.width && image.width && (setting.width < image.width || setting.height < image.height);
  }

  fetchSource(image) {
    return image.cropped || image.source;
  }

  render() {
    const { setting, getValue, handleChange } = this.props;
    const value = getValue(null);
    const image = value && typeof(value) === 'object' ? value : { source: value };

    return (
      <div className="editor-input editor-input-image-picker">
        <label className="editor-input--label">
          {setting.label}
        </label>

        {this.isCroppable(image, setting) && (
          <Modal
            title="Crop image"
            isOpen={this.state.isModalOpened}
            onClose={() => this.setState({ isModalOpened: false })}
          >
            <Cropper
              image={image}
              cropSize={{ width: setting.width, height: setting.height }}
              getThumbnail={this.props.api.getThumbnail}
              handleChange={this.handleCropChange}
            />
          </Modal>
        )}

        <div className="editor-input--image-picker">
          <div
            className="editor-input-image-picker--source"
            style={{ backgroundImage: this.fetchSource(image) ? `url(${this.fetchSource(image)})` : null }}
          ></div>

          <div className="editor-input-image-picker--actions">
            <button className="btn btn-default btn-sm" onClick={e => openLibrary({ setting, ...this.props})}>
              {value === null ? 'Select' : 'Change'}
            </button>
            &nbsp;
            {value !== null && (
              <button
                className="btn btn-default btn-sm"
                onClick={e => handleChange(null)}
              >
                Remove
              </button>
            )}
            &nbsp;
            {this.isCroppable(image, setting) && (
              <button
                className="btn btn-default btn-sm"
                onClick={e => this.setState({ isModalOpened: true })}
              >
                Crop
              </button>
            )}
          </div>
        </div>
      </div>
    );
  }
}

export default compose(
  withRouter,
  withRoutes,
  withRedux(state => ({ thumbnailPath: state.editor.urls.thumbnail }))
)(ImagePickerInput);
