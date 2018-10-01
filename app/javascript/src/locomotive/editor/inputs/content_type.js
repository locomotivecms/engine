import React from 'react';

const ContentTypeInput = ({ label, setting, getValue, handleChange, urls }) => (
  <div className="editor-input editor-input-text">
    <label className="editor-input--label">
      {label || setting.label}
    </label>
    <a href={urls['contentEntries'][getValue('')]}>
      {getValue('')}
    </a>
  </div>
)

export default ContentTypeInput;
