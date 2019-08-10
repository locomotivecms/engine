import React from 'react';
import Slider, { Range } from 'rc-slider';

import { isBlank, presence } from '../utils/misc';

function safeHandleChange(value, min, max, callback) {
  value = presence(value) || min;
  value = parseInt(value);

  if (value < min) value = min;
  if (value > max) value = max;

  callback(value);
}

function formattedValue(value, unit) {
  return isBlank(unit) ? value : `${value}${unit}`;
}

const SliderInput = ({ label, inputId, getValue, handleChange, setting }) => {
  const defaultValue  = presence(setting.default) || 0;
  const min           = presence(setting.min) || 0;
  const max           = presence(setting.max) || 100;
  const step          = presence(setting.step) || 1;

  return (
    <div className="editor-input editor-input-integer">
      <label className="editor-input--label" htmlFor={inputId}>
        <span className="editor-input--label--main">{label}</span>
        <span className="editor-input--label--value">{formattedValue(getValue(defaultValue), setting.unit)}</span>
      </label>
      <div>
        <Slider
          min={min}
          max={max}
          step={step}
          value={getValue(0)}
          onChange={value => safeHandleChange(value, min, max, handleChange)}
        />
      </div>
    </div>
  )
}

const SimpleInput = ({ label, inputId, getValue, handleChange, setting }) => {
  const step = presence(setting.step) || 1;

  return (
    <div className="editor-input editor-input-text editor-input-integer">
      <label className="editor-input--label" htmlFor={inputId}>
        {label}
      </label>
      <input
        id={inputId}
        type="number"
        step={step}
        value={getValue(0)}
        onChange={e => handleChange(e.target.value)}
        className="editor-input--text editor-input--integer"
      />
    </div>
  )
}

const IntegerInput = props => (
  (isBlank(props.setting.min) || isBlank(props.setting.max) ? (
    <SimpleInput {...props} />
  ) : (
    <SliderInput {...props} />
  ))
)

export default IntegerInput;
