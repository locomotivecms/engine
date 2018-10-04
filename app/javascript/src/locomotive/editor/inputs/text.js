import React from 'react';

const TextInput = ({ setting, getValue, getLabel, handleChange, error }) => (
  <div className="editor-input editor-input-text">
    <label className="editor-input--label">
      {getLabel(setting.label)}
      {error && (
        <span className="editor-input--error">
          {error[0]}
        </span>
      )}
    </label>
    <input
      type="text"
      value={getValue('')}
      onChange={e => handleChange(e.target.value)}
      className="editor-input--text"
    />

  </div>
)

export default TextInput;
