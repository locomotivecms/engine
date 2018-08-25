import React from 'react';

// Components
import Preset from './preset';

const Category = props => (
  <div className="editor-section-category">
    <div className="editor-section-category-name">
      <h3>{props.category.name}</h3>
    </div>
    <div className="editor-section-category-section-list">
      {props.category.presets.map(preset =>
        <Preset
          {...props}
          key={preset.type}
          preset={preset}
        />
      )}
    </div>
  </div>
)

export default Category;
