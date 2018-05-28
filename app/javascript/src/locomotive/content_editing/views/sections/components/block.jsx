import React, { Component } from 'react';
import { Link } from 'react-router-dom';

class Block extends Component {

  // Return the definition for the block
  getDefinition() {
    const { sectionDefinition, block } = this.props;
    return sectionDefinition.blocks.find(definition => definition.type === block.type)
  }

  render() {
    const { sectionDefinition, block, removeBlock, handleComponent } = this.props;
    const definition = this.getDefinition();

    const Handle = handleComponent;

    return (
      <div className="editor-section-block">
        <Handle />
        &nbsp;
        {definition.name} ({block.id})
        &nbsp;
        <Link to={`/sections/${sectionDefinition.type}/blocks/${block.id}/edit`}>Edit</Link>
        &nbsp;
        <a onClick={removeBlock}>Delete</a>
      </div>
    )
  }

}

export default Block;
