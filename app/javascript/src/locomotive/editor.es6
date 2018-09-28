import React from 'react';
import ReactDOM from 'react-dom';
import './editor.scss';
import App from './editor/app';

$(document).ready(function() {
  const { preview, base } = window.Locomotive.urls;

  ReactDOM.render(
    <App previewPath={preview} basePath={base} />, document.getElementById('editor-app'));
});

