import React, { Component } from 'react';
import { Link } from 'react-router-dom';

class Section extends Component {

  render() {
    const { section, removeSection, handleComponent } = this.props;
    const Handle = handleComponent;

    return <div>
      <Handle />
      &nbsp;
      {section.name}
      &nbsp;
      <Link to={`/dropzone_sections/${section.type}/${section.id}/edit`}>
        Edit
      </Link>
      &nbsp;
      <a onClick={removeSection}>Delete</a>
    </div>
  }

}

export default Section;
