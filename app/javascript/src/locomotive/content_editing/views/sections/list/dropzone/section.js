import React from 'react';
import { Link } from 'react-router-dom';

const Section = props => {
  const Handle = props.handleComponent;
  return (
    <div className="editor-section editor-dropzone-section">
      <div className="editor-section--icon">
        &nbsp;
      </div>
      <div className="editor-section--label">
        {props.section.label || props.section.name}
      </div>
      <div className="editor-section--actions">
        <Link to={props.editPath}>
          <i className="fas fa-edit"></i>
        </Link>
        <Handle />
      </div>
    </div>
  )
}

export default Section;
