import React, { Component } from 'react';
import { compose } from 'redux';
// import ReactCrop from 'react-image-crop';
import AvatarEditor from 'react-avatar-editor'
// import Cropper from 'react-cropper';
import { bindAll } from 'lodash';

// HOC
import { withRouter } from 'react-router-dom';
import withRoutes from '../hoc/with_routes';
import withRedux from '../hoc/with_redux';

// Components
import Modal from '../components/modal';

const openLibrary = props => {
  props.redirectTo(props.imagesPath(
    props.section,
    props.blockType,
    props.blockId,
    props.setting.type,
    props.setting.id
  ), 'left');
}

class Zero7 extends Component {

  constructor(props) {
    super(props);
    this.state = { scale: 1, position: { x: 0, y: 0 }, url: null }
    bindAll(this, 'handleScale', 'handlePositionChange', 'buildPreviewURL', 'handleChange');
    this.debouncedBuildPreviewURL = _.debounce(this.buildPreviewURL, 600, { maxWait: 3000 });
  }

  handleChange() {
    console.log({ ...this.props.image, cropped: this.state.url });
    this.props.handleChange({ ...this.props.image, cropped: this.state.url });
  }

  handlePositionChange(position) {
    this.setState({ position: position }, this.debouncedBuildPreviewURL);
  }

  handleScale(event) {
    this.setState({ scale: parseFloat(event.target.value) }, this.debouncedBuildPreviewURL);
  }

  buildPreviewURL() {
    const { getThumbnail, image, size } = this.props;
    const { position: { x, y }, scale } = this.state;

    // find the right cropping window
    const cropWidth   = image.width < size.width ? image.width : size.width;
    const cropHeight  = image.height < size.height ? image.height : size.height;

    // resize the original image
    const resizeWidth   = Math.round(cropWidth * scale);
    const resizeHeight  = Math.round((resizeWidth / image.width) * image.height);

    // top left corner where to crop from
    var cropX = Math.round((x - 0.5) * resizeWidth);
    var cropY = Math.round((y - 0.5) * resizeHeight);
    cropX = cropX < 0 ? `${cropX}` : `+${cropX}`;
    cropY = cropY < 0 ? `${cropY}` : `+${cropY}`;

    const format = `${resizeWidth}x${resizeHeight}|${cropWidth}x${cropHeight}${cropX}${cropY}`;

    // 1er: marche avec images dont la largeur < size.width
    // const format  = `${cropWith}x${cropHeight}+0+${Math.round(image.height * y - size.height / 2)}`;

    console.log('crop', format);

    getThumbnail(image.source, format).then(url => this.setState({ url }));

    // getThumbnail(image, format).then(path => this.setState({ url: path }));
  }

  render() {
    // FIXME: AVATAR EDITOR WIDTH = 500px
    const { image, size } = this.props;

    return <div className="zero7">
      <AvatarEditor
        image={image.source}
        width={850}
        height={(750 / size.width) * size.height}
        border={[150,250]}
        color={[200, 200, 200, 0.6]} // RGBA
        position={this.state.position}
        scale={this.state.scale}
        rotate={0}
        onPositionChange={this.handlePositionChange}
      />
      <input
        name="scale"
        type="range"
        onChange={this.handleScale}
        min="1"
        max="2"
        step="0.01"
        defaultValue="1"
      />
      <p>X = {this.state.position.x} / Y = {this.state.position.y} / scale: {this.state.scale}</p>
      <p>URL={this.state.url}</p>
      <p><a onClick={this.handleChange}>PROCESS</a></p>
    </div>
  }

}


// class Zero7 extends Component {

//   constructor(props) {
//     super(props);

//     const { cropSize, image } = props;

//     this.state = {
//       crop: {
//         x: 0,
//         y: 0,
//         width:  cropSize.width / image.width * 100,
//         aspect: cropSize.width / cropSize.height
//         // aspect: 16/9,
//         // width: 50
//       }
//     }

//     console.log('init', cropSize, image, cropSize.width / image.width * 100);

//     this.onChange = this.onChange.bind(this);
//   }

//   onChange(crop) {
//     this.setState({ crop });
//   }

//   render() {
//     const { cropSize, image } = this.props;
//     //

//     return (
//       <ReactCrop
//         src={this.props.image.source}
//         crop={this.state.crop}
//         onChange={this.onChange}
//         minWidth={cropSize.width / image.width * 100}
//         maxWidth={cropSize.width / image.width * 100}
//       />
//     )
//   }
// }

class ImagePickerInput extends Component {

  constructor(props) {
    super(props);
    this.state = { isModalOpened: false };
  }

  render() {
    const { setting, getValue, handleChange } = this.props;
    const value = getValue(null);
    const image = typeof(value) === 'object' ? value : { source: value };

    return (
      <div className="editor-input editor-input-image-picker">
        <label className="editor-input--label">
          {setting.label}
        </label>

        {value && setting.width && (
          <Modal isOpen={this.state.isModalOpened} onClose={() => this.setState({ isModalOpened: false })}>
            <Zero7
              image={image}
              size={{ width: setting.width, height: setting.height }}
              getThumbnail={this.props.api.getThumbnail}
              handleChange={handleChange}
            />
          </Modal>
        )}

        <div className="editor-input--image-picker">
          <div
            className="editor-input-image-picker--source"
            style={{ backgroundImage: image.source ? `url(${image.source})` : null }}
          ></div>

          <div className="editor-input-image-picker--actions">
            <button className="btn btn-primary btn-sm" onClick={e => openLibrary({ setting, ...this.props})}>
              {value === null ? 'Select' : 'Change'}
            </button>
            &nbsp;
            {value !== null && (
              <button
                className="btn btn-primary btn-sm"
                onClick={e => handleChange(null)}
              >
                Remove
              </button>
            )}
            &nbsp;
            {value && setting.width && image.width && (
              <button
                className="btn btn-primary btn-sm"
                onClick={e => this.setState({ isModalOpened: true })}
              >
                CROP! [NEW]
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

// VERSION 0

// class Zero7 extends Component {

//   constructor(props) {
//     super(props);
//   }

//   _crop() {
//     console.log(this.refs.cropper.getCroppedCanvas().toDataURL());
//   }

//   render() {
//     return (
//       <Cropper
//         ref='cropper'
//         src={this.props.image.source}
//         style={{ height: 400, width: '100%' }}
//         // Cropper.js options
//         aspectRatio={1920 / 320}
//         guides={false}
//         crop={this._crop.bind(this)}
//       />
//     )
//   }
// }
