import React, { Component } from 'react';

// Components
import UrlPicker from '../components/url_picker';

const UrlInput = props => (
  <div className="editor-input editor-input-url">
    <label>{props.setting.label}</label>
    <br/>
    <UrlPicker
      value={props.getValue(null)}
      handleChange={props.handleChange}
    />
  </div>
)

export default UrlInput;
