import React, { Component } from 'react';
import { SortableContainer, SortableElement, SortableHandle } from 'react-sortable-hoc';

// Services
import { findBetterImageAndText } from '../../../services/blocks_service';

// Components
import Block from './block';

// Sortable components
const DragHandle    = SortableHandle(() => (
  <div className="editor-list-item--drag-handle"><i className="fa fa-bars"></i></div>
));
const SortableBlock = SortableElement(Block);
const SortableList  = SortableContainer(({ blocks, ...props }) => (
  <div>
    {blocks.map((block, index) => {
      const definition = props.sectionDefinition.blocks.find(def => def.type === block.type)

      // verify that the block coming from the DB has still a definition
      if (definition === null || definition === undefined) return

      const { image, text } = findBetterImageAndText(block, definition)

      return (
        <SortableBlock
          key={`section-${props.sectionType}-block-${index}`}
          index={index}
          image={image}
          text={text}
          block={block}
          blockDefinition={definition}
          handleComponent={DragHandle}
          editPath={props.editBlockPath(props.section, block.type, block.id)}
        />
      )
    })}
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
