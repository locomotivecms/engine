import React from 'react';
import { Link } from 'react-router-dom';
import { truncate } from 'lodash';

// Components
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
        <Link to={editPath} className="editor-list-item--actions--button">
          <EditIcon />
        </Link>
        <Handle />
      </div>
    </div>
  )
}

export default Block;
