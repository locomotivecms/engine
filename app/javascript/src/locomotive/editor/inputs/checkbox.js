import React from 'react';

// Components
import Switch from '../components/switch';

const CheckboxInput = ({ label, setting, getValue, handleChange }) => (
  <div className="editor-input editor-input-checkbox">
    <label className="editor-input--label">
      {label || setting.label}
    </label>
    <div className="editor-input--button">
      <Switch
        checked={getValue(false)}
        onChange={value => handleChange(value)}
      />
    </div>
  </div>
)

export default CheckboxInput;
