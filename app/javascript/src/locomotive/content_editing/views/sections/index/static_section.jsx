import React from 'react';
import { Link } from 'react-router-dom';

const StaticSection = props => (
  <div className="editor-section">
    <p>
      {props.definition.name}
      &nbsp;
      <Link to={props.editPath}>Edit</Link>
    </p>
  </div>
)

export default StaticSection;
