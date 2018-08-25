import React, { Component } from 'react';
import { SortableContainer, SortableElement, SortableHandle } from 'react-sortable-hoc';

// Components
import Block from './block.jsx';

// Sortable components
const DragHandle    = SortableHandle(() => <span>::</span>);
const SortableBlock = SortableElement(Block);
const SortableList  = SortableContainer(({ blocks, ...props }) => (
  <div>
    {blocks.map((block, index) =>
      <SortableBlock
        key={`section-${props.sectionType}-block-${index}`}
        index={index}
        handleComponent={DragHandle}
        editPath={props.editBlockPath(props.section, block.type, block.id)}
        removeBlock={props.removeSectionBlock.bind(null, props.section, block.id)}
        block={block}
        {...props}
        blockDefinition={props.sectionDefinition.blocks.find(def => def.type === block.type)}
      />
    )}
  </div>
));

const BlockList = props => (
  <SortableList
    blocks={props.sectionContent.blocks || []}
    onSortEnd={props.moveBlock}
    useDragHandle={true}
    lockAxis="y"
    {...props}
  />
)

export default BlockList;
