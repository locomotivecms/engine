import React from 'react';

// Components
import Preset from './preset';

const Category = props => (
  <div className="editor-section--category">
    <div className="editor-section--category-name">
      {props.category.name}
    </div>
    <div className="editor-section--category-list">
      {props.category.presets.map(preset =>
        <Preset
          {...props}
          key={preset.type}
          preset={preset}
          definition={props.findSectionDefinition(preset.type)}
        />
      )}
    </div>
  </div>
)

export default Category;
