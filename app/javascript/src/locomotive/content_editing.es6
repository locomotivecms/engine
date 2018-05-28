import React from 'react';
import ReactDOM from 'react-dom';
import './content_editing.scss';
import App from './content_editing/app.jsx';

$(document).ready(function() {
  ReactDOM.render(
    <App
      urls={window.Locomotive.urls}
      {...window.Locomotive.data}
    />, document.getElementById('editor-app'));
});

