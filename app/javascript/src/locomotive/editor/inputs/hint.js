import React from 'react';

const HintInput = ({ setting, getValue, getLabel, handleChange }) => (
  <div className="editor-input editor-input-hint">
    <label className="editor-input--label">
      {getLabel(setting.label)}
    </label>
  </div>
)

export default HintInput;
