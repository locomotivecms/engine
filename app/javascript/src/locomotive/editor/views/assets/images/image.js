import React from 'react';

const Image = props => (
  <div className={`editor-image ${props.selected ? 'active' : ''}`}>
    <div className="editor-image--inner" onClick={props.handleSelect}>
      <img src={props.thumbnail_url} />
    </div>
  </div>
)

export default Image
