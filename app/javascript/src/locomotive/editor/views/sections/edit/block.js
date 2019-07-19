import React from 'react';
import { truncate } from 'lodash';

// Components
import { SlideLeftLink } from '../../../components/links';
import EditIcon from '../../../components/icons/edit';

const Block = ({ image, text, handleComponent, editPath, ...props }) => {
  const Handle = handleComponent;

  return (
    <div className="editor-list-item">
      <SlideLeftLink to={editPath}>
        {image && (
          <div className="editor-list-item--image" style={{ backgroundImage: `url("${image}")` }}>
          </div>
        )}
      </SlideLeftLink>
      <SlideLeftLink to={editPath} className="editor-list-item--label">
        {truncate(text || props.blockDefinition.name, { length: 32 })}
      </SlideLeftLink>
      <div className="editor-list-item--actions">
        <Handle />
      </div>
    </div>
  )
}

export default Block;
