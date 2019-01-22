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

// const getDisplayInfo(value) {
//   var _value = value;

//   if (typeof(value) !== 'Object')
//     _value = { type: '_external', value: value, label: ['_external', value], new_window: false };

//   switch(_value.type) {
//     case 'page':
//       return ['page', ]
//     case y:
//       // code block
//       break;
//     default:
//       // code block
//   }
// }

const getType = value => {
  if (typeof(value) === 'string')
    return '_external';

  const { type, label } = value;

  // TODO: translate type...
  return type === 'content_entry' ? label[0] : type;

  // switch(type) {
  //   case 'page':
  //   case '_external':
  //   case 'email':
  //     return type;
  //   case 'content_entry':
  //     return 'TODO';
  // }
}

const getLabel = value => {
  // special case: '#' for instance
  if (typeof(value) === 'string')
    return value;

  const { type, label } = value;

  return typeof(label) == 'array' ? label[1] : label;

  // switch(type) {
  //   case 'page':
  //   case '_external':
  //   case 'email':
  //     return typeof(label) == 'array' ? label[1] : label;
  //   case 'content_entry':
  //     return 'TODO';
  // }
}

const UrlInput = ({ label, getValue, handleChange, api, locale, ...props }) => {
  // console.log('rendering URL!!!!', getValue());

  const value = getValue(null);

  // console.log(value, getType(value), getLabel(value));

  return (
    <div className="editor-input editor-input-url">
      <label className="editor-input--label">
        {label}
      </label>

      {value && (
        <div className="editor-input-url--info">
          <div className="editor-input-url--info-type">
            {getType(value)}
          </div>
          <div className="editor-input-url--info-content">
            {getLabel(value)}
          </div>
        </div>
      )}

      {value === null && (
        <div className="editor-input-url--empty">
          No link (TODO)
        </div>
      )}

      <button onClick={() => openPicker(props)}>Change</button>
    </div>
  )
}

export default UrlInput;
