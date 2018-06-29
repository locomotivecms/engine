import React from 'react';

const TextInput = ({ setting, getValue, handleChange }) => (
  <div className="editor-input editor-input-text">
    <label>{setting.label}</label>
    <br/>
    <input
      type="text"
      value={getValue('')}
      onChange={e => handleChange(e.target.value)}
    />
  </div>
)

export default TextInput;
