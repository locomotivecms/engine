import React, { Component } from 'react';
import { bindActionCreators } from 'redux';
import { connect } from 'react-redux';
import * as actionCreators from '../actions/action_creators.js';
import { saveContent } from '../api.js';

class SaveButton extends React.Component {

  constructor(props) {
    super(props);
    this.save = this.save.bind(this);
  }

  save() {
    const { persistChanges, site, page } = this.props;

    saveContent(site, page)
    .then((data) => { persistChanges(true) })
    .catch((errors) => { persistChanges(false, errors) });
  }

  render() {
    return <button
      className="btn btn-primary btn-sm"
      onClick={this.save}
    >
      Save
    </button>
  }

}

function mapStateToProps(state) {
  return { site: state.site, page: state.page }
}

function mapDispachToProps(dispatch) {
  return bindActionCreators(actionCreators, dispatch);
}

export default connect(mapStateToProps, mapDispachToProps)(SaveButton);
