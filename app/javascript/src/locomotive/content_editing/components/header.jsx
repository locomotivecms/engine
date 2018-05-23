import React, { Component } from 'react';
import withRedux from '../utils/with_redux';

// Components
import SaveButton from './save_button.jsx';

const Header = (props) => (
  <div className="row header-row">
    <div className="col-md-8">
      <h1>{props.page.title}</h1>
    </div>
    <div className="col-md-4">
      <SaveButton />
    </div>
  </div>
)

export default withRedux(Header, state => { return { page: state.page } })
