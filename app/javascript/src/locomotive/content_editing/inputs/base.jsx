import React, { Component } from 'react';
import StringInput from './string.jsx';
import { bindActionCreators } from 'redux';
import { connect } from 'react-redux';
import * as actionCreators from '../actions/action_creators.js';

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

function mapStateToProps(state) {
  return { site: state.site, page: state.page }
}

function mapDispachToProps(dispatch) {
  return bindActionCreators(actionCreators, dispatch);
}

export default connect(mapStateToProps, mapDispachToProps)(Base);

