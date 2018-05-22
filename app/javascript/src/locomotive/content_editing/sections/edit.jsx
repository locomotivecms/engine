import React, { Component } from 'react';
import { Link } from 'react-router-dom';
import { bindActionCreators } from 'redux';
import { connect } from 'react-redux';
import * as actionCreators from '../actions/action_creators.js';
import { find } from 'lodash';
import Input from '../inputs/base.jsx';

class EditSection extends Component {

  getDefinition() {
    const { definitions, match } = this.props;
    return definitions.find(definition => definition.type === match.params.type)
  }

  getData(type) {
    const { sectionsContent } = this.props.site;
    return sectionsContent[type] || {};
  }

  render() {
    const definition = this.getDefinition();

    return (
      <div className="lce-edit-section">
        <p>TODO: EditSection / {definition.name}</p>
        <p>
          <Link to="/">Back</Link>
        </p>
        <div className="lce-field">
          {definition.settings.map(inputSettings =>
            <Input
              key={inputSettings.id}
              settings={inputSettings}
              data={this.getData(definition.type)}
              type="staticSection"
              sectionType={definition.type}
            />
          )}
        </div>
      </div>
    )
  }

}

function mapStateToProps(state) {
  return {
    site:         state.site,
    definitions:  state.sectionDefinitions
  }
}

function mapDispachToProps(dispatch) {
  return bindActionCreators(actionCreators, dispatch);
}

export default connect(mapStateToProps, mapDispachToProps)(EditSection);
