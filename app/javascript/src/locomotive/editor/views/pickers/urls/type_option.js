import React, { Component } from 'react';
import i18n from '../../../i18n';

const TypeOption = ({ value, currentValue, handleChange, ...props }) => (
  <div className="url-picker-type-option">
    <label>
      <input
        type="radio"
        name="url_picker_type"
        value={value}
        checked={currentValue === value}
        onChange={handleChange}
      />
      {i18n.t(`views.pickers.url.types.${value}`)}
    </label>
  </div>
)



export default TypeOption;
