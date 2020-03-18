import React, { Component } from 'react';
import { bindAll, values } from 'lodash';

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
import ContentTypeInput from './content_type';
import ContentEntryInput from './content_entry';
import HintInput from './hint';
import IntegerInput from './integer';

class Base extends Component {

  constructor(props) {
    super(props);
    bindAll(this, 'getValue', 'handleChange', 'getLocalizedLabel');
  }

  handleChange(value) {
    const { setting, handleChange } = this.props;
    handleChange(setting.type, setting.id, value);
  }

  getValue(undefinedValue) {
    const { setting, value } = this.props;
    return value === undefined ? setting.defaultValue || undefinedValue : value;
  }

  getLocalizedLabel(label) {
    if (typeof(label) === 'object')
      label = label[this.props.uiLocale] || values(label)[0];
    return label;
  }

  getInput(setting) {
    switch (setting.type) {
      case 'text':          return setting.html ? RichTextInput : TextInput;
      case 'integer':       return IntegerInput;
      case 'checkbox':      return CheckboxInput;
      case 'select':        return SelectInput;
      case 'radio':         return RadioInput;
      case 'image_picker':  return ImagePickerInput;
      case 'url':           return UrlInput;
      case 'content_type':  return ContentTypeInput;
      case 'content_entry': return ContentEntryInput;
      case 'hint':          return HintInput;
      default:
        console.log(`[Editor] Warning! Unknown input type: "${setting.type}"`);
        return null;
    }
  }

  render() {
    const Input = this.getInput(this.props.setting);

    if (this.props.isVisible === false)
      return null;

    return Input !== null ? (
      <Input
        label={this.getLocalizedLabel(this.props.setting.label)}
        inputId={`setting-${this.props.setting.type}-${this.props.setting.id}`}
        getLocalizedLabel={this.getLocalizedLabel}
        getValue={this.getValue}
        {...this.props}
        handleChange={this.handleChange}
      />
    ) : null;
  }

}

export default Base;
