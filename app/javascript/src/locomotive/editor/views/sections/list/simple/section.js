import React from 'react';
import { truncate } from 'lodash';
import classnames from 'classnames';

// Components
import { SlideLeftLink } from '../../../../components/links';
import Icons from '../../../../components/icons';
import EditIcon from '../../../../components/icons/edit';

// Services
import { isEditable } from '../../../../services/sections_service';

const Section = ({ image, text, section, definition, translate, separator, ...props })=> {
  const Icon  = Icons[definition.icon];

  return (
    <div className={classnames('editor-list-item', separator ? 'with-separator' : null)}>
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
          {truncate(text || section.label || translate(definition.name), { length: 32 })}
        </SlideLeftLink>
      </div>
      <div className="editor-list-item--actions">
      </div>
    </div>
  )
}

export default Section;
