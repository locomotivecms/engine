import React from 'react';
import { Link } from 'react-router-dom';

// Services
import { getLabelElements } from '../../../services/blocks_service';

// Components
import Label from './block_label.jsx';

const Block = props => {
  const { blockDefinition, block, removeBlock, handleComponent, editPath } = props;
  const Handle = handleComponent;

  return (
    <div className="editor-block">
      <Handle />
      <Label {...getLabelElements(blockDefinition, block)} />
      <div className="editor-block-actions">
        <Link to={editPath}>Edit</Link>
        &nbsp;
        <button className="btn-sm btn-primary btn-xs" onClick={removeBlock}>
          Delete
        </button>
      </div>
    </div>
  )
}

export default Block;
