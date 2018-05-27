import React, { Component } from 'react';
import StringInput from './string.jsx';
import CheckboxInput from './checkbox.jsx';
import withRedux from '../utils/with_redux';

class Base extends Component {

  // TODO: text, integer, float, image, boolean, select
  getInput() {
    switch (this.props.setting.type) {
      case 'string': return StringInput;
      default:
        console.log(`[Editor] Warning! Unknown input type: "${this.props.setting.type}"`);
        return null;
    }
  }

  render() {
    const Input = this.getInput();
    return Input !== null ? <Input {...this.props} /> : null;
  }

}

export default withRedux(Base, state => { return { site: state.site, page: state.page, iframe: state.iframe.window } });
