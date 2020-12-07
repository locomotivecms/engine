import React from 'react';
import i18n from '../../../i18n';

const Asset = props => (
  <div className={`editor-asset ${props.selected ? 'active' : ''}`}>
    <div className="editor-asset--inner" onClick={props.handleSelect}>
      <span className="editor-asset--type">{i18n.t(`views.pickers.assets.types.${props.content_type}`)}</span>
      <span className="editor-asset--filename">{props.source_filename}</span>
      <span className="editor-asset--size">{props.size_to_human}</span>
    </div>
  </div>
)

export default Asset
