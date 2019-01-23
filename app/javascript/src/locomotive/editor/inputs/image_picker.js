import React, { Component } from 'react';
import { compose } from 'redux';
import ReactCrop from 'react-image-crop';
import { bindAll } from 'lodash';
import i18n from '../i18n';

// HOC
import { withRouter } from 'react-router-dom';
import withRoutes from '../hoc/with_routes';
import withRedux from '../hoc/with_redux';

// Components
import Modal from '../components/modal';
import Cropper from '../components/cropper';

const openLibrary = props => {
  props.redirectTo(props.pickImagePath(
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
    const { setting, getValue, label, handleChange } = this.props;
    const value = getValue(null);
    const image = value && typeof(value) === 'object' ? value : { source: value };

    return (
      <div className="editor-input editor-input-image-picker">
        <label className="editor-input--label">
          {label}
        </label>

        {this.isCroppable(image, setting) && (
          <Modal
            title={i18n.t('components.cropper.title')}
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
            <button className="btn btn-default btn-sm" onClick={e => openLibrary({ setting, ...this.props })}>
              {i18n.t(value === null ? 'inputs.image_picker.select_button' : 'inputs.image_picker.change_button')}
            </button>
            &nbsp;
            {value !== null && (
              <button
                className="btn btn-default btn-sm"
                onClick={e => handleChange(null)}
              >
                {i18n.t('inputs.image_picker.remove_button')}
              </button>
            )}
            &nbsp;
            {this.isCroppable(image, setting) && (
              <button
                className="btn btn-default btn-sm"
                onClick={e => this.setState({ isModalOpened: true })}
              >
                {i18n.t('inputs.image_picker.crop_button')}
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
