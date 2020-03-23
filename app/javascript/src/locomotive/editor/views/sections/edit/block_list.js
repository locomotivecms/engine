import React from 'react';
import { DndProvider } from 'react-dnd';
import { Flipper, Flipped } from 'react-flip-toolkit';
import HTML5Backend from 'react-dnd-html5-backend';
import Sortly, { ContextProvider, useDrag, useDrop } from 'react-sortly';

// Components
import Block from './block';

// Services
import { findBetterImageAndText } from '../../../services/blocks_service';

const buildItems = props => {
  return (props.sectionContent.blocks || []).map(block => {
    const definition = props.sectionDefinition.blocks.find(def => def.type === block.type)

    if (definition === null || definition === undefined) return null;
    var { image, text } = findBetterImageAndText(block, definition)

    // we don't want the blocks to all have the same text
    if (text === null && block.index)
      text = `${definition.name} #${block.index}`

    return {
      block,
      text,
      image,
      id:              block.id,
      depth:           block.depth || 0,
      blockDefinition: definition,
      editPath:        props.editBlockPath(props.section, block.type, block.id)
    }
  });
}

const ItemRenderer = (props) => {
  const { data } = props;
  const [, drop] = useDrop();
  const [{ isDragging }, drag, preview] = useDrag({
    collect: (monitor) => ({
      isDragging: monitor.isDragging(),
    }),
  });

  return (
    <Flipped flipId={data.id}>
      <div ref={ref => drop(preview(ref))}>
        <div style={{ marginLeft: data.depth * 20 }}>
          <Block isDragging={isDragging} drag={drag} {...data} />
        </div>
      </div>
    </Flipped>
  );
};

const SortableTree = props => {
  const items = buildItems(props);
  const onChange = sortedItems => {
    props.moveBlock(
      sortedItems.map(item => ({ ...item.block, depth: item.depth }))
    );
  };

  return (
    <Flipper flipKey={items.map(({ id }) => id).join('.')} spring="stiff">
      <Sortly items={items} onChange={onChange} maxDepth={props.maxDepth}>
        {(props) => <ItemRenderer {...props} />}
      </Sortly>
    </Flipper>
  );
};

const BlockList = props => (
 <DndProvider backend={HTML5Backend}>
   <ContextProvider>
     <SortableTree {...props} />
   </ContextProvider>
 </DndProvider>
);

export default BlockList;
