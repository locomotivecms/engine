import React, { Component } from 'react';
import withRedux from '../hoc/with_redux';

// Components
import TextInput from './text.jsx';
import CheckboxInput from './checkbox.jsx';
import SelectInput from './select.jsx';
import RadioInput from './radio.jsx';
import ImagePickerInput from './image_picker.jsx';

class Base extends Component {

  getInput() {
    switch (this.props.setting.type) {
      case 'text':      return TextInput;
      case 'checkbox':  return CheckboxInput;
      case 'select':    return SelectInput;
      case 'radio':     return RadioInput;
      case 'image_picker':  return ImagePickerInput;
      default:
        console.log(`[Editor] Warning! Unknown input type: "${this.props.setting.type}"`);
        return null;
    }
  }

  componentDidMount() {
    this.props.editSetting(this.props.setting.type, this.props.setting.id);
  }

  render() {
    const Input = this.getInput();
    return Input !== null ? <Input {...this.props} /> : null;
  }

}

export default withRedux(state => { return { site: state.site, page: state.page } })(Base);
