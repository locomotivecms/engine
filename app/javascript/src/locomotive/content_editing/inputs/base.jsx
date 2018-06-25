import React, { Component } from 'react';

// HOC
import withRedux from '../hoc/with_redux';

// Components
import TextInput from './text.jsx';
import CheckboxInput from './checkbox.jsx';
import SelectInput from './select.jsx';
import ImagePickerInput from './image_picker.jsx';

const getInput = type => {
  switch (type) {
    case 'text':          return TextInput;
    case 'checkbox':      return CheckboxInput;
    case 'select':        return SelectInput;
    case 'image_picker':  return ImagePickerInput;
    default:
      console.log(`[Editor] Warning! Unknown input type: "${type}"`);
      return null;
  }
}

const Base = props => {
  const Input = getInput(props.setting.type);
  return Input !== null ? <Input {...props} /> : null;
}

export default withRedux(state => ({ site: state.site, page: state.page }))(Base);
