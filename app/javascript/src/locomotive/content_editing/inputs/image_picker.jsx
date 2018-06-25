import React, { Component } from 'react';
import { compose } from 'redux';
import { bindAll } from 'lodash';

// HOC
import { withRouter } from 'react-router-dom';
import withRoutes from '../hoc/with_routes';

class ImagePickerInput extends Component {

  constructor(props) {
    super(props);

    var value = props.data.settings[props.setting.id];
    if (value === undefined) value = props.setting.default || null;

    this.state = { value };

    bindAll(this, 'openLibrary');
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

    return (
      <div className="editor-input editor-input-image-picker">
        <label>{setting.label}</label>
        <br/>
        {this.state.value ? (
          <img src={this.state.value} className="editor-input-image-picker-src" />
        ) : (
          <p>No image</p>
        )}
        <br/>
        <div className="editor-input-image-picker-actions">
          <button className="btn btn-primary btn-sm" onClick={this.openLibrary}>
            {this.state.value === null ? 'Select' : 'Change'}
          </button>
          &nbsp;
          {this.state.value !== null && (
            <button className="btn btn-primary btn-sm">Remove</button>
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
