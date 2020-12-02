import React from 'react';
import withFocus from '../hoc/with_focus';

const TextInput = ({ label, inputId, getValue, handleChange, inputFocus, error }) => (
  <div className="editor-input editor-input-text">
    <label className="editor-input--label" htmlFor={inputId}>
      {label}
      {error && (
        <span className="editor-input--error">
          {error[0]}
        </span>
      )}
    </label>
    <input
      id={inputId}
      type="text"
      value={getValue('')}
      onChange={e => handleChange(e.target.value)}
      className="editor-input--text"
      ref={inputFocus.ref}
    />
  </div>
)

export default withFocus(TextInput);
