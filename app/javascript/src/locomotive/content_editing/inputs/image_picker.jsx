import React, { Component } from 'react';
import { compose } from 'redux';
import { bindAll } from 'lodash';

// HOC
import { withRouter } from 'react-router-dom';
import withRoutes from '../hoc/with_routes';

class ImagePickerInput extends Component {

  constructor(props) {
    super(props);
    bindAll(this, 'openLibrary');
  }

  getValue() {
    const { setting, data } = this.props;
    var value = data.settings[setting.id];

    return value === undefined ? setting.default || null : value;
  }

  openLibrary() {
    this.props.history.push(this.props.imagesBlockPath(
      this.props.sectionType,
      this.props.sectionId,
      this.props.blockType,
      this.props.blockId,
      this.props.setting.type,
      this.props.setting.id
    ));
  }

  render() {
    const { setting } = this.props;
    const value = this.getValue();

    return (
      <div className="editor-input editor-input-image-picker">
        <label>{setting.label}</label>
        <br/>
        {value ? (
          <img src={value} className="editor-input-image-picker-src" />
        ) : (
          <p>No image</p>
        )}
        <br/>
        <div className="editor-input-image-picker-actions">
          <button className="btn btn-primary btn-sm" onClick={this.openLibrary}>
            {value === null ? 'Select' : 'Change'}
          </button>
          &nbsp;
          {value !== null && (
            <button
              className="btn btn-primary btn-sm"
              onClick={this.props.onChange.bind(this, setting.type, setting.id, '')}
            >
              Remove
            </button>
          )}
        </div>
      </div>
    )
  }

}

export default compose(
  withRouter,
  withRoutes
)(ImagePickerInput);
