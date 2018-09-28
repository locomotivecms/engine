import React, { Component } from 'react';
import classnames from 'classnames';
import i18n from '../../i18n';

// Components
import SectionIcon from '../../components/icons/sections';
import SettingsIcon from '../../components/icons/settings';
import BarChartIcon from '../../components/icons/bar_chart';

// FIXME: Unfortunately, we can't use CSS in that case.
const Style = {
  navTabColor:        '#a6a6a6',
  navTabActiveColor:  '#595959'
}

const menuItemClassname = (tab, selectedTab) => {
  return classnames('nav-tab', tab === selectedTab ? 'active' : false);
}

const Menu = ({ selectedTab, onSelectTab }) => (
  <div className="editor-menu">
    <ul className="nav nav-tabs" role="tablist">
      <li className={menuItemClassname('sections', selectedTab)}>
        <a onClick={() => onSelectTab('sections')}>
          <SectionIcon color={Style.navTabActiveColor} />
          {i18n.t('views.action_bar.menu.content')}
        </a>
      </li>
      <li className={menuItemClassname('settings', selectedTab)}>
        <a onClick={() => onSelectTab('settings')}>
          <SettingsIcon color={Style.navTabColor} />
          {i18n.t('views.action_bar.menu.settings')}
        </a>
      </li>
      <li className={menuItemClassname('seo', selectedTab)}>
        <a onClick={() => onSelectTab('seo')}>
          <BarChartIcon color={Style.navTabColor} />
          {i18n.t('views.action_bar.menu.seo')}
        </a>
      </li>
    </ul>
  </div>
)

export default Menu;
