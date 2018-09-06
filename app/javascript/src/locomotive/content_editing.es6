import React from 'react';
import ReactDOM from 'react-dom';
import './content_editing.scss';
import App from './content_editing/app';

$(document).ready(function() {
  const { preview, base } = window.Locomotive.urls;

  ReactDOM.render(
    <App previewPath={preview} basePath={base} />, document.getElementById('editor-app'));
});

