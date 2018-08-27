import React from 'react';
import { Link } from 'react-router-dom';

// Components
import HeaderIcon from '../../../../components/icons/header';

const Section = props => {
  const label = props.section.label || props.definition.name;

  return (
    <div className="editor-section">
      <div className="editor-section--icon">
        <HeaderIcon />
      </div>
      <div className="editor-section--label">
        {label}
      </div>
      <div className="editor-section--actions">
        <Link to={props.editPath}>
          <i className="fas fa-edit"></i>
        </Link>
      </div>
    </div>
  )
}

export default Section;
