import React from 'react';
import { Link } from 'react-router-dom';

// Components
import Icons from '../../../../components/icons';
import EditIcon from '../../../../components/icons/edit';

const Section = props => {
  const Handle  = props.handleComponent;
  const Icon    = Icons[props.definition.icon];

  return (
    <div className="editor-section editor-dropzone-section">
      <div className="editor-section--icon">
        {Icon && <Icon />}
      </div>
      <div className="editor-section--label">
        {props.section.label || props.section.name}
      </div>
      <div className="editor-section--actions">
        <Link to={props.editPath} className="editor-section--actions--button">
          <EditIcon />
        </Link>
        <Handle />
      </div>
    </div>
  )
}

export default Section;
