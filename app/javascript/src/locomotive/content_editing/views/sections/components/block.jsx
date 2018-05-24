import React, { Component } from 'react';
import { Link } from 'react-router-dom';

class Block extends Component {

  constructor(props) {
    super(props);
    this.removeBlock = this.removeblock.bind(this);
  }

  // Return the definition for the block
  getDefinition() {
    const { sectionDefinition, block } = this.props;
    return sectionDefinition.blocks.find(definition => definition.type === block.type)
  }

  removeblock() {
    const { sectionDefinition, block } = this.props;
    this.props.removeBlock(sectionDefinition.type, block.id);
  }

  render() {
    const definition = this.getDefinition();

    return (
      <div className="editor-section-block">
        {definition.name} ({this.props.block.id})
        &nbsp;
        <Link to={`/sections/${this.props.sectionDefinition.type}/edit`}>Edit</Link>
        &nbsp;
        <a onClick={this.removeBlock}>Delete</a>
      </div>
    )
  }

}

export default Block;
