import React from 'react';
import i18n from '../../../i18n';

const iconClassName = contentType => {
  switch (contentType) {
    case 'image': return 'far fa-file-image fa-lg';
    case 'pdf': return 'far fa-file-pdf fa-lg';
    case 'media': return 'far fa-file-video fa-lg'
    default: 
      return 'far fa-file'
  }
  
}

const Asset = props => (
  <div className="editor-list-item" onClick={props.handleSelect}>
    <div className="editor-list-item--icon">
      <i className={iconClassName(props.content_type)}></i>
    </div>
    <div className="editor-list-item--label">{props.source_filename}</div>
    <div className="editor-list-item--actions">
      <small>{props.size_to_human}</small>
    </div>
  </div>
)

export default Asset
