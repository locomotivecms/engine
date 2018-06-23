import React, { Component } from 'react';
import { Link } from 'react-router-dom';

class Block extends Component {

  render() {
    const { blockDefinition, block, removeBlock, handleComponent, routes } = this.props;
    const Handle = handleComponent;

    return (
      <div className="editor-section-block">
        <Handle />
        &nbsp;
        {blockDefinition.name} ({block.id})
        &nbsp;
        <Link to={routes.editBlockPath(block.type, block.id)}>Edit</Link>
        &nbsp;
        <a onClick={removeBlock}>Delete</a>
      </div>
    )
  }

}

export default Block;
