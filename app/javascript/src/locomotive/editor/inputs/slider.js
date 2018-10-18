import React from 'react';

const SliderInput = ({ setting, getValue, handleChange }) => (
  <div className="editor-input editor-input-slider">
    <label>{setting.label}</label>
    <br/>
    <input
      type='range'
      min={setting.min}
      max={setting.max}
      value={getValue(null)}
      onChange={e => handleChange(e.target.value)} />
  </div>
)

export default SliderInput;
