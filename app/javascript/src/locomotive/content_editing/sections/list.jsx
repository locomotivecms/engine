import React, { Component } from 'react';
import { Link } from 'react-router-dom';
import { bindActionCreators } from 'redux';
import { connect } from 'react-redux';
import * as actionCreators from '../actions/action_creators.js';
import { find } from 'lodash';

class Section extends Component {

  render() {
    return (
      <div className="lce-section">
        <p>
          {this.props.definition.name}
          &nbsp;
          <Link to={`/sections/${this.props.sectionType}/edit`}>Edit</Link>
        </p>
      </div>
    )
  }

}

class List extends Component {

  getDefinition(type) {
    return find(this.props.definitions, definition => definition.type === type)
  }

  render() {
    return (
      <div className="lce-section-list">
        {this.props.list.map(type =>
          <Section key={type} sectionType={type} definition={this.getDefinition(type)} />
        )}
      </div>
    )
  }

}

function mapStateToProps(state) {
  return { list: state.site.staticSections, definitions: state.sectionDefinitions }
}

function mapDispachToProps(dispatch) {
  return bindActionCreators(actionCreators, dispatch);
}

export default connect(mapStateToProps, mapDispachToProps)(List);
