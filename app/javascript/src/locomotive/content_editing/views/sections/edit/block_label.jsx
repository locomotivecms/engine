import React from 'react';

const BlockLabel = ({ name, image }) => (
  <div className="editor-block-label">
    {image && (
      <div className="editor-block-image">
        <img src={image} />
      </div>
    )}
    <div className="editor-block-name">
      {name}
    </div>
  </div>
)

export default BlockLabel;
