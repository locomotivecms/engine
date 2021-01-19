import React, { Component } from 'react';
import { Link } from 'react-router-dom';
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

const getType = url => url.type === 'content_entry' && url.label ? url.label[0] : i18n.t(`inputs.url.types.${url.type}`);
const getLabel = url => {
  if (url.type === '_external' || url.type === 'email')
    return url.value
  else if (url.label)
    return url.label[1];
  else
    return null;
}
const isLocalUrl = url => url && (url.type === 'content_entry' || url.type === 'page');
const editPagePath = (url, buildPath) => {
  return url.type === 'page' ? buildPath(url.value) : buildPath(url.value.page_id, url.value.id);
}

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
        {isLocalUrl(url) && (
          <a href={editPagePath(url, props.editPagePath)} className="btn btn-default btn-sm mr-3">
            <i className="fas fa-external-link-alt"></i>
          </a>
        )}
        <button className="btn btn-default btn-sm" onClick={e => openPicker(props)}>
          {i18n.t(url === null ? 'inputs.url.select_button' : 'inputs.url.change_button')}
        </button>
        {url !== null && (
          <button
            className="btn btn-default btn-sm ml-3"
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
