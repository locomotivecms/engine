import React from 'react';
import Popover from 'react-awesome-popover';
import i18n from '../../../i18n';

const NewBlockPicker = ({ sectionDefinition, addBlock, ...props }) => (
  <div className="editor-section-blocks--new">

    {sectionDefinition.blocks.length === 1 && (
      <div className="editor-list-add">
        <a className="editor-list-add--button" onClick={addBlock.bind(null, null)}>
          {i18n.t('views.sections.edit.add_block')}
        </a>
      </div>
    )}

    {sectionDefinition.blocks.length > 1 && (
      <Popover placement="bottom">
        <button className="editor-list-add--button">
          {i18n.t('views.sections.edit.add_block')}
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
