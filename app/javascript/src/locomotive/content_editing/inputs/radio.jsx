import React, { Component } from 'react';

const RadioInput = ({ setting, getValue, handleChange }) => (
  <div className="editor-input editor-input-radio">
    <label>{setting.label}</label>
    <br/>
    {setting.options.map((option, index) =>
      <div className="editor-input-radio-option" key={`radio-${index}`}>
        <input
          type="radio"
          id={option.value}
          onChange={e => handleChange(e.target.id)}
          checked={getValue(null) === option.value}
        />
        &nbsp;
        {option.label}
      </div>
    )}
  </div>
)

export default RadioInput;
