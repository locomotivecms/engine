import React, { Component } from 'react';
import { isBlank } from '../../utils/misc';
import i18n from '../../i18n';

// Components
import ResourceLabel from './resource_label';

const UrlInfo = ({ value, handleEditing, handleDone }) => (
  <div className="url-picker-info">
    {isBlank(value) ? (
      <div className="url-picker-info--value editor-input--text is-blank">
        {i18n.t('components.url_picker.no_url')}
      </div>
    ) : (
      <div className="url-picker-info--value editor-input--text">
        <ResourceLabel value={value.label[0]} />
        &nbsp;
        {value.label[1]}
      </div>
    )}
    <div className="url-picker-info--actions">
      <button className="btn btn-sm btn-default" onClick={handleEditing}>
        {i18n.t('components.url_picker.change_button')}
      </button>
      {handleDone && (
        <button className="btn btn-sm btn-default" onClick={handleDone}>
          {i18n.t('components.url_picker.done_button')}
        </button>
      )}
    </div>
  </div>
)

export default UrlInfo;
