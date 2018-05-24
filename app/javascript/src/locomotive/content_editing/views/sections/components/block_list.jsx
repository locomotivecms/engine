import React, { Component } from 'react';
import withRedux from '../../../utils/with_redux';
import { build as buildBlock } from '../../../services/blocks_service';

// Components
import Popover from 'react-awesome-popover';
import Block from './block.jsx';

class BlockList extends Component {

  constructor(props) {
    super(props);
    this.addBlock = this.addBlock.bind(this);
  }

  addBlock(blockType) {
    const { sectionDefinition } = this.props;
    const block = buildBlock(sectionDefinition, blockType || sectionDefinition.blocks[0].type);

    this.props.addStaticSectionBlock(sectionDefinition.type, block);
  }

  render() {
    const { blocks } = this.props.content;
    const { sectionDefinition, removeStaticSectionBlock } = this.props;

    return (
      <div className="editor-section-blocks">
        <h3>Blocks</h3>
        {(blocks || []).map((block, index) =>
          <Block
            key={`section-${sectionDefinition.type}-block-${index}`}
            sectionDefinition={sectionDefinition}
            block={block}
            removeBlock={removeStaticSectionBlock}
          />)}
        <div className="editor-section-add-block text-center">
          {sectionDefinition.blocks.length === 1 && (
            <button className="btn btn-primary btn-sm" onClick={this.addBlock.bind(null, null)}>
              Add block
            </button>
          )}

          {sectionDefinition.blocks.length > 1 && (
            <Popover placement="bottom">
              <button className="btn btn-primary btn-sm">
                Add block
              </button>
              <div className="rap-popover-pad">
                {sectionDefinition.blocks.map(blockDefinition =>
                  <div
                    key={`add-block-${blockDefinition.type}`}
                    className="rap-popover-button-wrapper">
                    <button onClick={this.addBlock.bind(null, blockDefinition.type)}>
                      {blockDefinition.name}
                    </button>
                  </div>
                )}
              </div>
            </Popover>
          )}
        </div>
      </div>
    )
  }

}

export default withRedux(BlockList, state => { return { site: state.site } });
