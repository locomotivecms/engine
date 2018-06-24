import React from 'react';
import { Link } from 'react-router-dom';

const Block = props => {
  const { blockDefinition, block, removeBlock, handleComponent, editPath } = props;
  const Handle = handleComponent;

  return (
    <div className="editor-section-block">
      <Handle />
      &nbsp;
      {blockDefinition.name} ({block.id})
      &nbsp;
      <Link to={editPath}>Edit</Link>
      &nbsp;
      <a onClick={removeBlock}>Delete</a>
    </div>
  )
}

export default Block;
