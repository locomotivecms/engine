import React, { Component } from 'react';

const Select = ({ label, value, onChange, list, getValue, getName, includeEmpty, ...props }) => (
  <div className="editor-input editor-input-select">
    <label className="editor-input--label">
      {label}
    </label>
    <div className="editor-input-select-wrapper">
      <select
        value={value}
        onChange={e => onChange(e.target.value)}
        className="editor-input--select"
      >
        {includeEmpty && <option></option>}
        {list.map((option, index) =>
          <option key={index} value={option[1]}>
            {option[0]}
          </option>
        )}
      </select>
    </div>
  </div>
)

export default Select;
