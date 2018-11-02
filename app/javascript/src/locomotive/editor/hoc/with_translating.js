import React from 'react';
import { values } from 'lodash';

export default function withTranslating(Component) {

  const translate = (locale, value, defaultValue) => {
    if (typeof(value) === 'object')
      return value[locale] || defaultValue || values(value)[0];
    else
      return value || defaultValue;
  }

  return function WrappedComponent(props) {
    return <Component
      translate={translate.bind(null, props.uiLocale)}
      {...props}
    />
  }

}
