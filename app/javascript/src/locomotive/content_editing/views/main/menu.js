import React, { Component } from 'react';
import { compose } from 'redux';
import { Link } from 'react-router-dom';

// Components
import SectionIcon from '../../components/icons/sections';
import SettingsIcon from '../../components/icons/settings';
import BarChartIcon from '../../components/icons/bar_chart';

// HOC
import withRoutes from '../../hoc/with_routes';
import withRedux from '../../hoc/with_redux';

// Style
const Style = {
  navTabColor: '#a6a6a6',
  navTabActiveColor: '#595959'
}

const Menu = props => (
  <div className="editor-menu">
    <ul className="nav nav-tabs" role="tablist">
      <li className="nav-tab active">
        <Link to={props.sectionsPath()}>
          <SectionIcon color={Style.navTabActiveColor} />
          Content
        </Link>
      </li>
      <li className="nav-tab">
        <a href="#">
          <SettingsIcon color={Style.navTabColor} />
          Settings
        </a>
      </li>
      <li className="nav-tab">
        <a href="#">
          <BarChartIcon color={Style.navTabColor} />
          SEO
        </a>
      </li>
    </ul>
  </div>
)

export default compose(
  withRedux(state => ({
  })),
  withRoutes
)(Menu)
