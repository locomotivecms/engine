import React from 'react';
import ReactDOM from 'react-dom';
import './content_editing.scss';
import App from './content_editing/app.jsx';

$(document).ready(function() {
  const { urls } = window.Locomotive;
  ReactDOM.render(<App urls={urls} />, document.getElementById('editor-app'));
});

