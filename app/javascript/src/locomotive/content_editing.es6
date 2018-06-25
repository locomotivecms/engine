import React from 'react';
import ReactDOM from 'react-dom';
import './content_editing.scss';
import App from './content_editing/app.jsx';

$(document).ready(function() {
  const { urls, data } = window.Locomotive;

  const hasSections = data.sections.all.length > 0 || data.sections.dropzone;
  const hasEditableElements = data.editableElements.length > 0;

  ReactDOM.render(
    <App
      urls={urls}
      hasSections={hasSections}
      hasEditableElements={hasEditableElements}
      {...data}
    />, document.getElementById('editor-app'));
});

