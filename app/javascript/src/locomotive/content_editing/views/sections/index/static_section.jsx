import React from 'react';
import { Link } from 'react-router-dom';

const StaticSection = props => (
  <div className="editor-section">
    <div className="editor-section-label">
      {props.definition.name}
    </div>
    <div className="editor-section-actions">
      <Link to={props.editPath}>Edit</Link>
    </div>
  </div>
)

export default StaticSection;
