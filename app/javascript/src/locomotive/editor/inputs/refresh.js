import React from 'react';

const RefreshInput = ({ label, setting, getValue, handleChange }) => (
  <div className="editor-input">
    <div className="editor-input--button">
      <button className='btn btn-primary btn-save'
        value={getValue(true)}
        onClick={e => handleChange(!getValue(true))} >
        <span>
          {label || setting.label}
        </span>
      </button>
    </div>
  </div>
)

export default RefreshInput;
