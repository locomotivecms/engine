import React, { Component } from 'react';
import StringInput from './string.jsx';
import withRedux from '../utils/with_redux';

class Base extends Component {

  // TODO: text, integer, float, image, boolean, select
  getInput() {
    const { type } = this.props.settings;

    switch (type) {
      case 'string': return StringInput;
      default: return null;
    }
  }

  render() {
    const Input = this.getInput();
    return <Input {...this.props} />;
  }

}

export default withRedux(Base, state => { return { site: state.site, page: state.page, iframe: state.iframe.window } });
