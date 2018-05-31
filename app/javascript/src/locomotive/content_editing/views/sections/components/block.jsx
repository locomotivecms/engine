import React, { Component } from 'react';
import { Link } from 'react-router-dom';

class Block extends Component {

  // Return the definition for the block
  getDefinition() {
    const { sectionDefinition, block } = this.props;
    return sectionDefinition.blocks.find(definition => definition.type === block.type)
  }

  getEditPath() {
    const { sectionDefinition, sectionId, block } = this.props;
    const prefix = sectionId ?
      `/dropzone_sections/${sectionDefinition.type}/${sectionId}` :
      `/sections/${sectionDefinition.type}`;

    return `${prefix}/blocks/${block.type}/${block.id}/edit`
  }

  render() {
    const { block, removeBlock, handleComponent } = this.props;
    const definition = this.getDefinition();

    const Handle = handleComponent;

    return (
      <div className="editor-section-block">
        <Handle />
        &nbsp;
        {definition.name} ({block.id})
        &nbsp;
        <Link to={this.getEditPath()}>Edit</Link>
        &nbsp;
        <a onClick={removeBlock}>Delete</a>
      </div>
    )
  }

}

export default Block;
