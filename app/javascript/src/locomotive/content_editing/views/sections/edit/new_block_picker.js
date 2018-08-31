import React from 'react';
import Popover from 'react-awesome-popover';

const NewBlockPicker = ({ sectionDefinition, addBlock, ...props }) => (
  <div className="editor-section-add-block text-center">
    {sectionDefinition.blocks.length === 1 && (
      <button className="btn btn-primary btn-sm" onClick={addBlock.bind(null, null)}>
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
              <button onClick={addBlock.bind(null, blockDefinition.type)}>
                {blockDefinition.name}
              </button>
            </div>
          )}
        </div>
      </Popover>
    )}
  </div>
)

export default NewBlockPicker;
