import React, { Component } from 'react';
import withRedux from '../../../utils/with_redux';
import { build as buildBlock } from '../../../services/blocks_service';
import { SortableContainer, SortableElement, SortableHandle } from 'react-sortable-hoc';

// Components
import Popover from 'react-awesome-popover';
import Block from './block.jsx';

// Sortable components
const DragHandle = SortableHandle(() => <span>::</span>);

const SortableBlock = SortableElement(Block);

const SortableList = SortableContainer(({ blocks, sectionDefinition, removeStaticSectionBlock }) => {
  return (
    <div>
      {(blocks || []).map((block, index) =>
        <SortableBlock
          key={`section-${sectionDefinition.type}-block-${index}`}
          index={index}
          sectionDefinition={sectionDefinition}
          block={block}
          removeBlock={removeStaticSectionBlock.bind(null, sectionDefinition.type, block.id)}
          handleComponent={DragHandle}
        />
      )}
    </div>
  );
});

class BlockList extends Component {

  constructor(props) {
    super(props);

    // bind methods to this
    this.addBlock   = this.addBlock.bind(this);
    this.onSortEnd  = this.onSortEnd.bind(this);
  }

  addBlock(blockType) {
    const { sectionDefinition } = this.props;
    const block = buildBlock(sectionDefinition, blockType || sectionDefinition.blocks[0].type);

    this.props.addStaticSectionBlock(sectionDefinition.type, block);
  }

  onSortEnd({ oldIndex, newIndex }) {
    const { moveStaticSectionBlock, sectionDefinition } = this.props;
    moveStaticSectionBlock(sectionDefinition.type, oldIndex, newIndex);
  }

  render() {
    const { blocks } = this.props.content;
    const { sectionDefinition, removeStaticSectionBlock } = this.props;

    return (
      <div className="editor-section-blocks">
        <h3>Blocks</h3>

        <SortableList
          blocks={blocks}
          sectionDefinition={sectionDefinition}
          onSortEnd={this.onSortEnd}
          removeStaticSectionBlock={removeStaticSectionBlock}
          useDragHandle={true}
          lockAxis="y"
        />

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
