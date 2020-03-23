import React from 'react';
import { truncate } from 'lodash';

// Components
import { SlideLeftLink } from '../../../components/links';
import EditIcon from '../../../components/icons/edit';

const Block = ({ image, text, handleComponent, editPath, isDragging, ...props }) => {
  const Handle = handleComponent;

  return (
    <div className={`editor-list-item ${isDragging ? 'editor-list-item--dragging' : ''}`}>
      {image && (
        <div className="editor-list-item--image" style={{ backgroundImage: `url("${image}")` }}>
        </div>
      )}
      <div className="editor-list-item--label">
        <SlideLeftLink to={editPath}>
          {truncate(text || props.blockDefinition.name, { length: 32 })}
        </SlideLeftLink>
      </div>
      <div className="editor-list-item--actions">
        <div ref={props.drag} className="editor-list-item--drag-handle">
          <i className="fa fa-bars"></i>
        </div>
      </div>
    </div>
  )
}

export default Block;
