import React, { Component } from 'react';
import i18n from '../../../../i18n';

const Email = ({ settings, handleChange, ...props }) => (
  <div className="url-picker-email-settings">
    <div className="editor-input editor-input-text">
      <label className="editor-input--label">
        {i18n.t('views.pickers.url.email.label')}
      </label>
      <input
        type="text"
        value={settings.value}
        onChange={e => handleChange({ ...settings, value: e.target.value, label: e.target.value })}
        placeholder={i18n.t('views.pickers.url.email.placeholder')}
        className="editor-input--text"
      />
    </div>
  </div>
)

export default Email;
