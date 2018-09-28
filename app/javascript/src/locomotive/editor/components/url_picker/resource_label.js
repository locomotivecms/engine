import React, { Component } from 'react';
import { lowerCase } from 'lodash';
import i18n from '../../i18n';

const translateLabel = label => {
  const key = lowerCase(label);
  return i18n.t(`components.url_picker.types.${key}`, { defaultValue: label })
}

const UrlPickerResourceLabel = ({ value, ...props }) => (
  <span className="label label-primary">
    {translateLabel(value)}
  </span>
)

export default UrlPickerResourceLabel;
