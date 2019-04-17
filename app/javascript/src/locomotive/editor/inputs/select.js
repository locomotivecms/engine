import React from 'react';

const SelectInput = ({ label, inputId, setting, getValue, getLocalizedLabel, handleChange }) => {

  return (
    <div className="editor-input editor-input-select">
      <label htmlFor={inputId}>{label}</label>
      <br/>
      <div className="editor-input-select-wrapper">
        <select
          id={inputId}
          value={getValue(null)}
          onChange={e => handleChange(e.target.value)}
          className="editor-input--select"
        >
          {(setting.options || []).map((option, index) =>
            <option key={index} value={option.value}>
              {getLocalizedLabel(option.label)}
            </option>
          )}
        </select>
      </div>
    </div>
  )
}

export default SelectInput;
