import React, { Component } from 'react';
import i18n from '../../../../i18n';

// Components
import Switch from '../../../../components/switch';

const ExternalUrl = ({ settings, handleChange, ...props }) => (
  <div className="url-picker-external-settings">
    <div className="editor-input editor-input-text">
      <label className="editor-input--label">
        {i18n.t('views.pickers.url._external.label')}
      </label>
      <input
        type="text"
        value={settings.value}
        onChange={e => handleChange({ ...settings, value: e.target.value, label: e.target.value })}
        placeholder={i18n.t('views.pickers.url._external.placeholder')}
        className="editor-input--text"
      />
    </div>
    <div className="editor-input editor-input-checkbox">
      <label className="editor-input--label">
        {i18n.t('views.pickers.url.open_new_window')}
      </label>
      <div className="editor-input--button">
        <Switch
          checked={settings.new_window}
          onChange={value => handleChange({ ...settings, new_window: value })}
        />
      </div>
    </div>
  </div>
)

export default ExternalUrl;
