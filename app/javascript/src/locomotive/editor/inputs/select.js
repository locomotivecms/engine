import React from 'react';

const SelectInput = ({ label, setting, getValue, getLocalizedLabel, handleChange }) => {

  return (
    <div className="editor-input editor-input-select">
      <label>{label}</label>
      <br/>
      <div className="editor-input-select-wrapper">
        <select
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
