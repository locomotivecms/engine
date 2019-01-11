import React, { Component } from 'react';

// Components
// import UrlPicker from '../components/url_picker';

// <UrlPicker
//       value={getValue(null)}
//       handleChange={handleChange}
//       searchForResources={api.searchForResources}
//       locale={locale}
//     />

const openPicker = props => {
  props.redirectTo(props.pickUrlPath(
    props.section,
    props.blockType,
    props.blockId,
    props.setting.type,
    props.setting.id
  ), 'left');
}

const UrlInput = ({ label, getValue, handleChange, api, locale, ...props }) => (
  <div className="editor-input editor-input-url">
    <label className="editor-input--label">
      {label}
    </label>

    <pre>{getValue(null)}</pre>

    <button onClick={() => openPicker(props)}>Change</button>
  </div>
)

export default UrlInput;
