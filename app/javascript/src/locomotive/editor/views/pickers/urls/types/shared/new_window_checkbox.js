import React, { Component } from 'react';

// Components
import Switch from '../../../../../components/switch';

const NewWindowCheckbox = ({ label, checked, onChange, ...props }) => (
  <div className="editor-input editor-input-checkbox">
    <label className="editor-input--label">
      {label}
    </label>
    <div className="editor-input--button">
      <Switch
        checked={checked}
        onChange={value => onChange(value)}
      />
    </div>
  </div>
)

export default NewWindowCheckbox;

