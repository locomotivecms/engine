import React from 'react';
import { Link } from 'react-router-dom';
import { truncate } from 'lodash';

// Components
import Icons from '../../../../components/icons';
import EditIcon from '../../../../components/icons/edit';

const Section = ({ image, text, ...props }) => {
  const Handle  = props.handleComponent;
  const Icon    = Icons[props.definition.icon];

  return (
    <div className="editor-section editor-dropzone-section">
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
        {truncate(text || props.section.label || props.section.name, { length: 32 })}
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
