import React from 'react';
import { Link } from 'react-router-dom';

const Section = props => {
  const label = props.section.label || props.definition.name;

  return (
    <div className="editor-section">
      <div className="editor-section-label">
        {label}
      </div>
      <div className="editor-section-actions">
        <Link to={props.editPath}>Edit</Link>
      </div>
    </div>
  )
}

export default Section;
