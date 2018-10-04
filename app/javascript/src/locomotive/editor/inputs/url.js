import React, { Component } from 'react';

// Components
import UrlPicker from '../components/url_picker';

const UrlInput = ({ label, getValue, handleChange, api, locale }) => (
  <div className="editor-input editor-input-url">
    <label className="editor-input--label">
      {label}
    </label>
    <UrlPicker
      value={getValue(null)}
      handleChange={handleChange}
      searchForResources={api.searchForResources}
      locale={locale}
    />
  </div>
)

export default UrlInput;
