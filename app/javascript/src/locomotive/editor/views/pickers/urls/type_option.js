import React, { Component } from 'react';
import classnames from 'classnames';
import i18n from '../../../i18n';

const TypeOption = ({ value, currentValue, handleChange, ...props }) => (
  <div className={classnames('url-picker-type-option', currentValue === value && 'url-picker-type-option--checked')}>
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
