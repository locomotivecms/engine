import React from 'react';

const CheckboxInput = ({ setting, getValue, handleChange }) => (
  <div className="editor-input editor-input-text">
    <input
      type="checkbox"
      checked={getValue(false)}
      onChange={e => handleChange(e.target.checked)}
    />
    <label>{setting.label}</label>
  </div>
)

export default CheckboxInput;
