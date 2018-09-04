import React, { Component } from 'react';
import { compose } from 'redux';
import { Link } from 'react-router-dom';
import classnames from 'classnames';

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

const PathRegexps = {
  sections: /^\/[0-9a-z]+\/content\/edit\/sections\/?/,
  settings: /^\/[0-9a-z]+\/content\/edit\/settings\/?/,
  seo: /^\/[0-9a-z]+\/content\/edit\/seo\/?/
}

const menuItemClassname = (name, props) => {
  const location = props.history.location.pathname;
  const isActive = PathRegexps[name].test(location);
  return classnames('nav-tab', isActive ? 'active' : false);
}

const Menu = props => (
  <div className="editor-menu">
    <ul className="nav nav-tabs" role="tablist">
      <li className={menuItemClassname('sections', props)}>
        <Link to={props.sectionsPath()}>
          <SectionIcon color={Style.navTabActiveColor} />
          Content
        </Link>
      </li>
      <li className={menuItemClassname('settings', props)}>
        <Link to={props.settingsPath()}>
          <SettingsIcon color={Style.navTabColor} />
          Settings
        </Link>
      </li>
      <li className={menuItemClassname('seo', props)}>
        <Link to={props.seoPath()}>
          <BarChartIcon color={Style.navTabColor} />
          SEO
        </Link>
      </li>
    </ul>
  </div>
)

export default compose(
  withRedux(state => ({
  })),
  withRoutes
)(Menu)
