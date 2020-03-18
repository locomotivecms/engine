import React, { Component } from 'react';
import i18n from '../i18n';

const openPicker = props => {
  props.redirectTo(props.pickContentEntryPath(
    props.section,
    props.blockType,
    props.blockId,
    props.setting.type,
    props.setting.id
  ), 'left');
}

const getLabel = entry => entry.label ? entry.label : entry.id;

const ContentEntryInput = ({ label, getValue, handleChange, api, locale, ...props }) => {
  var entry = getValue(null);

  return (
    <div className="editor-input editor-input-content-entry">
      <label className="editor-input--label">
        {label}
      </label>

      {entry && (
        <div className="editor-input-content-entry--info">
          <div className="editor-input-content-entry--info-label">
            {getLabel(entry)}
          </div>
        </div>
      )}

      <div className="editor-input-content-entry--actions">
        <button className="btn btn-default btn-sm" onClick={e => openPicker(props)}>
          {i18n.t(entry === null ? 'inputs.content_entry.select_button' : 'inputs.content_entry.change_button')}
        </button>
        &nbsp;
        {entry !== null && (
          <button
            className="btn btn-default btn-sm"
            onClick={e => handleChange(null)}
          >
            {i18n.t('inputs.content_entry.remove_button')}
          </button>
        )}
      </div>
    </div>
  )
}

export default ContentEntryInput;
