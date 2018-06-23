import React, { Component } from 'react';
import withRedux from '../../../hoc/with_redux';
import { build as buildBlock } from '../../../services/blocks_service';
import { SortableContainer, SortableElement, SortableHandle } from 'react-sortable-hoc';
import { bindAll } from 'lodash';

// Components
import Popover from 'react-awesome-popover';
import Block from './block.jsx';

// Sortable components
const DragHandle    = SortableHandle(() => <span>::</span>);
const SortableBlock = SortableElement(Block);
const SortableList  = SortableContainer(({ blocks, ...props }) => {
  return (
    <div>
      {(blocks || []).map((block, index) =>
        <SortableBlock
          key={`section-${props.sectionType}-block-${index}`}
          index={index}
          handleComponent={DragHandle}
          removeBlock={props.removeSectionBlock.bind(null, props.sectionType, props.sectionId, block.id)}
          block={block}
          {...props}
          blockDefinition={props.sectionDefinition.blocks.find(def => def.type === block.type)}
        />
      )}
    </div>
  );
});

class BlockList extends Component {

  constructor(props) {
    super(props);
    bindAll(this, 'addBlock', 'onSortEnd');
  }

  addBlock(blockType) {
    this.props.addSectionBlock(
      this.props.sectionType,
      this.props.sectionId,
      buildBlock(
        this.props.sectionDefinition,
        blockType || this.props.sectionDefinition.blocks[0].type
      )
    )
  }

  onSortEnd({ oldIndex, newIndex }) {
    this.props.moveSectionBlock(
      this.props.sectionType,
      this.props.sectionId,
      oldIndex,
      newIndex
    )
  }

  render() {
    const { sectionDefinition, sectionContent } = this.props;

    return (
      <div className="editor-section-blocks">
        <h3>Blocks</h3>

        <SortableList
          blocks={sectionContent.blocks}
          onSortEnd={this.onSortEnd}
          useDragHandle={true}
          lockAxis="y"
          {...this.props}
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

export default BlockList;

// export default withRedux(state => { return { site: state.site } })(BlockList);
