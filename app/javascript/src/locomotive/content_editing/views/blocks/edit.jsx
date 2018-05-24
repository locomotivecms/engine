import React, { Component } from 'react';
import { Link } from 'react-router-dom';
import withRedux from '../utils/with_redux';
import { find } from 'lodash';

class Edit extends Component {

  render() {
    return <p>TODO: EDIT stuff</p>
  }

}

export default withRedux(Edit, state => { return {
  list: state.site.staticSections, definitions: state.sectionDefinitions
} });
