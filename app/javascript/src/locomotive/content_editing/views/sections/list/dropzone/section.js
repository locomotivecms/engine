import React from 'react';
import { Link } from 'react-router-dom';

const Section = props => {
  const Handle = props.handleComponent;
  return (
    <div className="editor-section editor-dropzone-section">
      <Handle />
      <div className="editor-section--label">
        {props.section.name}
      </div>
      <div className="editor-section--actions">
        <Link to={props.editPath}>Edit</Link>
      </div>
    </div>
  )
}

export default Section;
