import React, { Component } from 'react';
import { bindAll } from 'lodash';

// HOC
import withRedux from '../hoc/with_redux';

// Components
import TextInput from './text';
import RichTextInput from './rich_text';
import CheckboxInput from './checkbox';
import SelectInput from './select';
import RadioInput from './radio';
import ImagePickerInput from './image_picker';
import UrlInput from './url';

class Base extends Component {

  constructor(props) {
    super(props);
    bindAll(this, 'getValue', 'handleChange');
  }

  handleChange(value) {
    const { setting, handleChange } = this.props;
    handleChange(setting.type, setting.id, value);
  }

  getValue(undefinedValue) {
    const { setting, data } = this.props;
    var value = data.settings[setting.id];
    return value === undefined ? setting.defaultValue || undefinedValue : value;
  }

  getInput(setting) {
    switch (setting.type) {
      case 'text':          return setting.html ? RichTextInput : TextInput;
      case 'checkbox':      return CheckboxInput;
      case 'select':        return SelectInput;
      case 'radio':         return RadioInput;
      case 'image_picker':  return ImagePickerInput;
      case 'url':           return UrlInput;
      default:
        console.log(`[Editor] Warning! Unknown input type: "${setting.type}"`);
        return null;
    }
  }

  render() {
    const Input = this.getInput(this.props.setting);

    return Input !== null ? (
      <Input
        getValue={this.getValue}
        {...this.props}
        handleChange={this.handleChange}
      />
    ) : null;
  }

}

export default Base;
