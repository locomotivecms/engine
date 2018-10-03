import React from 'react';

const HintInput = ({ label, setting, getValue, getLabel, handleChange }) => (
  <div className="editor-input editor-input-hint">
    <label className="editor-input--label">
      {getLabel(null)}
    </label>
  </div>
)

export default HintInput;
