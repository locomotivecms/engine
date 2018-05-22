import React, { Component } from 'react';
import { bindActionCreators } from 'redux';
import { connect } from 'react-redux';
import * as actionCreators from './actions/action_creators.js';
import SaveButton from './components/save_button.jsx';

const Header = (props) => (
  <div className="row header-row">
    <div className="col-md-8">
      <h1>{props.page.title}</h1>
    </div>
    <div className="col-md-4">
      <SaveButton />
    </div>
  </div>
)

function mapStateToProps(state) {
  return { page: state.page }
}

function mapDispachToProps(dispatch) {
  return bindActionCreators(actionCreators, dispatch);
}

export default connect(mapStateToProps, mapDispachToProps)(Header);
