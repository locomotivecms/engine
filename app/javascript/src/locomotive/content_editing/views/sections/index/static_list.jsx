import React, { Component } from 'react';
import { Link } from 'react-router-dom';
import withRedux from '../../../hoc/with_redux';
import { find } from 'lodash';

class Section extends Component {

  render() {
    return (
      <div className="editor-section">
        <p>
          {this.props.definition.name}
          &nbsp;
          <Link to={`/sections/${this.props.sectionType}/edit`}>Edit</Link>
        </p>
      </div>
    )
  }

}

export class StaticList extends Component {

  getDefinition(type) {
    return find(this.props.definitions, definition => definition.type === type)
  }

  render() {
    return (
      <div className="editor-section-static-list">
        {this.props.list.map(type =>
          <Section key={type} sectionType={type} definition={this.getDefinition(type)} />
        )}
      </div>
    )
  }

}

export default withRedux(state => { return {
  definitions: state.sectionDefinitions
} })(StaticList);
