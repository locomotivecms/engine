import React from 'react';

const TextInput = ({ setting, getValue, handleChange }) => (
  <div className="editor-input editor-input-text">
    <label className="editor-input--label">
      {setting.label}
    </label>
    <input
      type="text"
      value={getValue('')}
      onChange={e => handleChange(e.target.value)}
      className="editor-input--text"
    />
  </div>
)

export default TextInput;
