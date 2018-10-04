import React from 'react';

const SelectInput = ({ label, setting, getValue, getLocalizedLabel, handleChange }) => {

  return (
    <div className="editor-input editor-input-select">
      <label>{label}</label>
      <br/>
      <select
        value={getValue(null)}
        onChange={e => handleChange(e.target.value)}
      >
        {(setting.options || []).map((option, index) =>
          <option key={index} value={option.value}>
            { getLocalizedLabel(option.label) }
          </option>
        )}
      </select>
    </div>
  )
}

export default SelectInput;
