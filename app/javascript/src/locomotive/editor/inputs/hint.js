import React from 'react';

const HintInput = ({ label, setting, getValue, handleChange }) => {
  console.log(getValue())
  return (<div className="editor-input editor-input-text">
    <label className="editor-input--label">
      {label || setting.label}
    </label>
    <p>
      {getValue('')}
    </p>
  </div>
)}

export default HintInput;
