import React from 'react';

const CheckboxInput = ({ setting, getValue, handleChange }) => (
  <div className="editor-input editor-input-checkbox">
    <input
      type="checkbox"
      checked={getValue(false)}
      onChange={e => handleChange(e.target.checked)}
    />
    <label className="editor-input--label">
      {setting.label}
    </label>
  </div>
)

export default CheckboxInput;
