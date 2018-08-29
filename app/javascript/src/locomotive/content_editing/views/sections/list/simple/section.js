import React from 'react';
import { Link } from 'react-router-dom';

// Components
import Icons from '../../../../components/icons';
import EditIcon from '../../../../components/icons/edit';

const Section = ({ image, text, section, definition, ...props })=> {
  const Icon = Icons[definition.icon];

  return (
    <div className="editor-section">
      {image && (
        <div className="editor-section--image" style={{ backgroundImage: `url("${image}")` }}>
        </div>
      )}
      {!image && (
        <div className="editor-section--icon">
          {Icon && <Icon />}
        </div>
      )}
      <div className="editor-section--label">
        {text || section.label || definition.name}
      </div>
      <div className="editor-section--actions">
        <Link to={props.editPath} className="editor-section--edit-button">
          <EditIcon />
        </Link>
      </div>
    </div>
  )
}

export default Section;
