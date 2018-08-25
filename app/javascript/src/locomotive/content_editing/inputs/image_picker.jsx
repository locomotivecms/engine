import React, { Component } from 'react';
import { compose } from 'redux';

// HOC
import { withRouter } from 'react-router-dom';
import withRoutes from '../hoc/with_routes';

const openLibrary = props => {
  props.redirectTo(props.imagesPath(
    props.section,
    props.blockType,
    props.blockId,
    props.setting.type,
    props.setting.id
  ));
}

const ImagePickerInput = ({ setting, getValue, handleChange, ...props }) => {
  const value = getValue(null);
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
        <button className="btn btn-primary btn-sm" onClick={e => openLibrary({ setting, ...props})}>
          {value === null ? 'Select' : 'Change'}
        </button>
        &nbsp;
        {value !== null && (
          <button
            className="btn btn-primary btn-sm"
            onClick={e => handleChange('')}
          >
            Remove
          </button>
        )}
      </div>
    </div>
  )
}

export default compose(
  withRouter,
  withRoutes
)(ImagePickerInput);
