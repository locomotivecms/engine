import React from 'react';
import i18n from '../i18n';

const ContentTypeInput = ({ label, setting, getValue, getLabel, handleChange, urls }) => (
  <div className="editor-input editor-input-content-type">
    <label className="editor-input--label">
      {getLabel(null)}
    </label>
    <a href={urls['contentEntries'][setting.id]} className="btn btn-default btn-sm editor-input--action">
      {i18n.t('inputs.content_type.show')}
    </a>
  </div>
)

export default ContentTypeInput;
