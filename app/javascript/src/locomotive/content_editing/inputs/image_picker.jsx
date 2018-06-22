import React, { Component } from 'react';
import { withRouter } from 'react-router-dom';

class ImagePickerInput extends Component {

  constructor(props) {
    super(props);

    var value = props.data.settings[props.setting.id];
    if (value === undefined) value = props.setting.default || null;

    this.state = { value };

    this.openLibrary = this.openLibrary.bind(this);
  }

  openLibrary() {
    console.log(this.props);
    // this.props.history.push('/images');
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

export default withRouter(ImagePickerInput);
