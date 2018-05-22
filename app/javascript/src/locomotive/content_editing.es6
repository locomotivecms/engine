import React from 'react';
import ReactDOM from 'react-dom';
import './content_editing.scss';
import App from './content_editing/app.jsx';

$(document).ready(function() {
  ReactDOM.render(<App />, document.getElementById('content-editing-app'));
});

