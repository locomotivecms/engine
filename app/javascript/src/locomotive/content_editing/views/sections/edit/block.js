import React from 'react';
import { truncate } from 'lodash';

// Components
import { SlideLeftLink } from '../../../components/links';
import EditIcon from '../../../components/icons/edit';

const Block = ({ image, text, handleComponent, editPath, ...props }) => {
  const Handle = handleComponent;

  return (
    <div className="editor-list-item">
      {image && (
        <div className="editor-list-item--image" style={{ backgroundImage: `url("${image}")` }}>
        </div>
      )}
      <div className="editor-list-item--label">
        {truncate(text || props.blockDefinition.name, { length: 32 })}
      </div>
      <div className="editor-list-item--actions">
        <SlideLeftLink to={editPath} className="editor-list-item--actions--button">
          <EditIcon />
        </SlideLeftLink>
        <Handle />
      </div>
    </div>
  )
}

export default Block;
