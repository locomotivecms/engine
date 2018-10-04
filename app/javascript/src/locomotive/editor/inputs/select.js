import React from 'react';

const SelectInput = ({ setting, getValue, getLabel, getLocalizedOptionLabel, handleChange, uiLocale }) => {

  return (
    <div className="editor-input editor-input-select">
      <label>{getLabel(null)}</label>
      <br/>
      <select
        value={getValue(null)}
        onChange={e => handleChange(e.target.value)}
      >
        {(setting.options || []).map((option, index) =>
          <option key={index} value={option.value}>
            { getLocalizedOptionLabel(option, uiLocale) }
          </option>
        )}
      </select>
    </div>
  )
}

export default SelectInput;
