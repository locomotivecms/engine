import React, { Component } from 'react';
import { compose } from 'redux';
import { Link } from 'react-router-dom';

// HOC
import withRoutes from '../../hoc/with_routes';
import withRedux from '../../hoc/with_redux';

const Menu = props => (
  <div className="editor-menu">
    <ul className="nav nav-tabs" role="tablist">
      <li className="nav-tab active">
        <Link to={props.sectionsPath()}>Content</Link>
      </li>
      <li className="nav-tab">
        <a href="#">Settings</a>
      </li>
      <li className="nav-tab">
        <a href="#">SEO</a>
      </li>
    </ul>
  </div>
)

export default compose(
  withRedux(state => ({
  })),
  withRoutes
)(Menu)
