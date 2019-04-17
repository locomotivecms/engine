import React from 'react';
import { truncate } from 'lodash';

// Components
import { SlideLeftLink } from '../../../../components/links';
import Icons from '../../../../components/icons';
import EditIcon from '../../../../components/icons/edit';

const Section = ({ image, text, ...props }) => {
  const Handle  = props.handleComponent;
  const Icon    = Icons[props.definition.icon] || Icons.default;

  return (
    <div className="editor-list-item editor-dropzone-section">
      {image && (
        <div className="editor-list-item--image" style={{ backgroundImage: `url("${image}")` }}>
        </div>
      )}
      {!image && (
        <div className="editor-list-item--icon">
          {Icon && <Icon />}
        </div>
      )}
      <div className="editor-list-item--label">
        <SlideLeftLink to={props.editPath}>
          {truncate(text || props.section.label || props.section.name || props.definition.name, { length: 32 })}
        </SlideLeftLink>
      </div>
      <div className="editor-list-item--actions">
        <Handle />
      </div>
    </div>
  )
}

export default Section;
