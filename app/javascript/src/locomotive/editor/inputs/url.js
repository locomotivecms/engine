import React, { Component } from 'react';

// Components
import UrlPicker from '../components/url_picker';

const UrlInput = props => (
  <div className="editor-input editor-input-url">
    <label className="editor-input--label">
      {props.getLabel()}
    </label>
    <UrlPicker
      value={props.getValue(null)}
      handleChange={props.handleChange}
      searchForResources={props.api.searchForResources}
      locale={props.locale}
    />
  </div>
)

export default UrlInput;
