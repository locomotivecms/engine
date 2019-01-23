import React, { Component } from 'react';
import i18n from '../i18n';

const openPicker = props => {
  props.redirectTo(props.pickUrlPath(
    props.section,
    props.blockType,
    props.blockId,
    props.setting.type,
    props.setting.id
  ), 'left');
}

const getType = url => url.type === 'content_entry' ? url.label[0] : i18n.t(`inputs.url.types.${url.type}`);
const getLabel = url => url.type === '_external' || url.type === 'email' ? url.value : url.label[1];

const UrlInput = ({ label, getValue, handleChange, api, locale, ...props }) => {
  var url = getValue(null);

  // special case: the value is a string (like #)
  if (typeof(url) === 'string') url = { type: '_external', value: url };

  return (
    <div className="editor-input editor-input-url">
      <label className="editor-input--label">
        {label}
      </label>

      {url && (
        <div className="editor-input-url--info">
          <div className="editor-input-url--info-type">
            <span className="label label-primary">
              {getType(url)}
            </span>
          </div>
          <div className="editor-input-url--info-label">
            {getLabel(url)}
          </div>
        </div>
      )}

      <div className="editor-input-url--actions">
        <button className="btn btn-default btn-sm" onClick={e => openPicker(props)}>
          {i18n.t(url === null ? 'inputs.url.select_button' : 'inputs.url.change_button')}
        </button>
        &nbsp;
        {url !== null && (
          <button
            className="btn btn-default btn-sm"
            onClick={e => handleChange(null)}
          >
            {i18n.t('inputs.url.remove_button')}
          </button>
        )}
      </div>
    </div>
  )
}

export default UrlInput;
