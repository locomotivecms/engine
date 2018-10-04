import React, { Component } from 'react';

const RadioInput = ({ setting, getValue, label, getLocalizedLabel, handleChange }) => (
  <div className="editor-input editor-input-radio">
    <label className="editor-input--label">
      {label}
    </label>
    <div className="editor-input--radio">
      {setting.options.map((option, index) =>
        <div className="editor-input-radio--option" key={`radio-${index}`}>
          <input
            type="radio"
            id={option.value}
            onChange={e => handleChange(e.target.id)}
            checked={getValue(null) === option.value}
          />
          {getLocalizedLabel(option.label)}
        </div>
      )}
    </div>
  </div>
)

export default RadioInput;
