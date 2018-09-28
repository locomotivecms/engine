import React from 'react';

const ContentTypeInput = ({ label, setting, getValue, handleChange }) => (
  <div className="editor-input editor-input-text">
    <label className="editor-input--label">
      {label || setting.label}
    </label>
    <h2 class='hint'>
      {getValue('')}
    </h2>
  </div>
)

export default ContentTypeInput;
