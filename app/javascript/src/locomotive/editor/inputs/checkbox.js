import React from 'react';

// Components
import Switch from '../components/switch';

const CheckboxInput = ({ label, setting, getValue, getLabel, handleChange }) => (
  <div className="editor-input editor-input-checkbox">
    <label className="editor-input--label">
      {getLabel(null)}
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
